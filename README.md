
# Deploying OpenNebula as a Hosted Cloud on Scaleway

This repository delivers the Terraform, Ansible, and driver customizations required to build an OpenNebula Hosted Cloud on **Scaleway Elastic Metal**. It extends the upstream [one-deploy](https://github.com/OpenNebula/one-deploy) and [one-deploy-validation](https://github.com/OpenNebula/one-deploy-validation) projects via git submodules and adds Scaleway-specific infrastructure modules, inventories, and Flexible IP (FIP) drivers.

Use the in-repo [deployment guide](./deployment_guide.md) for a narrative, end-to-end walkthrough; the README below highlights the main entry points and recent platform changes.

## Table of Contents

- [Scaleway Hosted Cloud Overview](#scaleway-hosted-cloud-overview)
- [Requirements](#requirements)
- [Repository Setup](#repository-setup)
- [Secrets and Environment Variables](#secrets-and-environment-variables)
- [Infrastructure Provisioning](#infrastructure-provisioning)
- [Inventory and Parameters](#inventory-and-parameters)
- [Networking Configuration](#networking-configuration)
- [OpenNebula Deployment Workflow](#opennebula-deployment-workflow)
- [Validation Suite](#validation-suite)
- [Troubleshooting & Known Issues](#troubleshooting--known-issues)
- [CI/CD Roadmap](#cicd-roadmap)
- [Extending the Cloud](#extending-the-cloud)

## Scaleway Hosted Cloud Overview

- Target architecture runs one OpenNebula frontend (also acting as a KVM node) and one or more KVM hypervisors on EM-A610R-NVMe servers connected through a private VPC and optional public Flexible IPs.
- Terraform modules under `scw/` create networking (VPC, VLANs, Flexible IP routing), bare-metal instances, and dynamic inventories.
- Ansible roles in `submodule-one-deploy` configure OpenNebula, while `roles/one-driver` provides a custom VNM bridge hook to allocate/detach Flexible IPs through Scaleway APIs (reworked in commits `967216f` and `a165376` to handle multi-NIC workloads).
- `deployment_guide.md` documents the architecture diagrams, hardware SKUs, and provisioning prerequisites in detail.

## Requirements

| Component | Version / Notes |
|-----------|-----------------|
| OpenTofu  | ≥ 1.5.0 (used by the `scw/*` modules) |
| Python / pip | Needed for [hatch](https://hatch.pypa.io) and Ansible tooling |
| Hatch     | Used to manage the `scaleway-default` execution environment |
| Ansible   | Driven by the `Makefile` targets |
| Scaleway Credentials | API access key, secret key, organization/project IDs |

Manual prerequisites (before automation):

- Create a Scaleway project (Console: Account > Projects) and an API key with `ElasticMetalFullAccess` + `IPAMFullAccess` (Console: IAM > API Keys). No bare-metal server needs to be pre-created—the Terraform modules provision the Elastic Metal servers and also create the Flexible IP IAM application/token automatically in module `005`.

Install the local tooling:

```bash
pip install hatch
make submodule-requirements     # installs collection dependencies via submodule-one-deploy
```

## Repository Setup

```bash
git clone https://github.com/OpenNebula/hosted-cloud-scaleway.git
cd hosted-cloud-scaleway
git submodule update --init --remote --merge
```

Makefile shortcuts (`deployment`, `validation`, `specifics`, `submodule-requirements`) proxy into the submodules with the Scaleway inventory pre-selected.

## Secrets and Environment Variables

Setup follows the template in `.secret.skel`:

```bash
cp .secret.skel .secret
vim .secret               # fill TF_VAR_*, SCW_* values, Flexible IP token, OpenNebula password, etc.
source .secret
```

Key variables:

- `TF_VAR_customer_name`, `TF_VAR_project_name`, `TF_VAR_project_fullname` — naming for resources/state (keep names as-is, only change values).
- `TF_VAR_state_infrastructure_information` — object with `scw_infrastructure_project_name` (used to name the dedicated state project); `TF_VAR_tfstate` — bucket prefix for remote state. These two must be set or `tofu plan` will prompt.
- `SCW_ACCESS_KEY` / `SCW_SECRET_KEY` plus `SCW_DEFAULT_ORGANIZATION_ID`, `SCW_DEFAULT_REGION`, and `SCW_DEFAULT_ZONE`. `SCW_DEFAULT_PROJECT_ID` is optional (not used by the modules).
- `TF_VAR_scw_secret_key` — required input to module `005`, keep the name unchanged and set it to `$SCW_SECRET_KEY`.
- Network inputs: `TF_VAR_private_subnet` (management subnet) and `TF_VAR_vmtovm_subnet` (VXLAN mesh subnet), plus `TF_VAR_worker_count` (number of hypervisors).
- AWS-compatible aliases (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) used by the state backend (keep the names as-is).
- The Flexible IP IAM application, policy, and token are created for you in module `005` and injected into `inventory/scaleway.yml` (`scw_flexible_ip_token`). You do **not** need to pre-create or store this token in `.secret`.

Example fill (replace with your IDs, zones, and secrets):

```bash
export TF_VAR_customer_name='opennebula'
export TF_VAR_project_name='scw'
export SCW_ACCESS_KEY='<scw-access-key>'
export SCW_SECRET_KEY='<scw-secret-key>'
export TF_VAR_scw_secret_key=$SCW_SECRET_KEY   # required; name must stay as-is
export AWS_ACCESS_KEY_ID=$SCW_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$SCW_SECRET_KEY
export SCW_DEFAULT_ORGANIZATION_ID='<org-id>'
export SCW_DEFAULT_REGION='fr-par'
export SCW_DEFAULT_ZONE='fr-par-2'
export TF_VAR_state_infrastructure_information='{ scw_infrastructure_project_name = "infra"}'
export TF_VAR_region=$SCW_DEFAULT_REGION
export TF_VAR_zone=$SCW_DEFAULT_ZONE
export TF_VAR_tfstate='opennebula-scw-infra-tfstates'
export TF_VAR_project_fullname='opennebula-scw-infra'
export TF_VAR_private_subnet="10.16.0.0/20"
export TF_VAR_vmtovm_subnet="172.16.24.0/22"
export TF_VAR_worker_count="1"
export TF_VAR_one_password='<oneadmin-password>'
```

> `.secret` stays ignored; never commit credential material.

## Infrastructure Provisioning

Modules under `scw/` are executed sequentially (OpenTofu CLI):

| Order | Module | Purpose |
|-------|--------|---------|
| 001 | `terraform_state_management` | Bootstrap state bucket/project metadata |
| 002 | `vpc` | Create VPC, subnets, VLAN assignments |
| 003 | `opennebula_instances` | Provision frontend & hypervisors + cloud-init assets |
| 004 | `opennebula_instances_net` | Configure networking (netplan, bridges, VLAN tags) |
| 005 | `opennebula_inventories` | Render `inventory/scaleway.yml` from module outputs |

Example run (after `source .secret`):

```bash
cd scw/002.vpc
tofu init
tofu plan -input=false   # surfaces any missing TF_VAR_* instead of prompting
tofu apply
cd ../..

# run each module in order (no loops to keep debugging simple)
cd scw/001.terraform_state_management && tofu init && tofu plan -input=false && tofu apply && cd ../..
cd scw/002.vpc                      && tofu init && tofu plan -input=false && tofu apply && cd ../..
cd scw/003.opennebula_instances     && tofu init && tofu plan -input=false && tofu apply && cd ../..
cd scw/004.opennebula_instances_net && tofu init && tofu plan -input=false && tofu apply && cd ../..
cd scw/005.opennebula_inventories   && tofu init && tofu plan -input=false && tofu apply && cd ../..
```

Consult `deployment_guide.md#4-infrastructure-deployment-tofu-modules` for module-specific inputs, expected outputs, and screenshots.

## Inventory and Parameters

`inventory/scaleway.yml` is auto-generated by module 005 but can be overridden for PoCs. Adapt these key parameters:

| Description | Variable(s) | Files / Templates |
|-------------|-------------|-------------------|
| SSH user, key path | `ansible_user`, `ansible_ssh_private_key_file` | `inventory/group_vars/all.yml` |
| Frontend + node metadata | `frontend.hosts.*`, `node.hosts.*` | `inventory/scaleway.yml` |
| Scaleway project / Flexible IP identifiers | `scw_project_id`, `scw_server_id`, `scw_flexible_ip_token`, `scw_flexible_ip_zone` | `inventory/scaleway.yml`, `roles/one-driver/defaults/main.yaml` |
| OpenNebula credentials | `one_pass`, `one_version` | `inventory/scaleway.yml`, `.secret` |
| VNM templates | `vn.pubridge.template.*`, `vn.vxlan.template.*` | `inventory/scaleway.yml` |
| Validation knobs | `validation.*` | `inventory/group_vars/all.yml` |

`inventory/group_vars/all.yml` also defines which cloud validation tests will be executed (core services, storage/network benchmarks, connectivity matrix, marketplace VM instantiation, etc.).

## Networking Configuration

- Cloud-init assets under `scw/004.opennebula_instances_net/template/` apply a deterministic netplan layout: `br0` for public/FIP traffic, `brvmtovm` for host-to-host VXLAN (`vmtovm` altname), and VLAN subinterfaces for private routing.
- `cloud_init_custom.tmpl` hard-codes `enp5s0` as the bare-metal NIC and wires in Tofu outputs such as `base_public_ip`, `gateway`, `private_network_vlan_assignment`, `vmtovm_vlan_assignment`, and IPAM settings.
- After provisioning, run an Ansible ping to verify reachability:

```bash
ansible -i inventory/scaleway.yml all -m ping -b
```

Refer to `deployment_guide.md#5-inventory-validation-ansible` for expected output and troubleshooting tips (missing SSH key, mismatch between generated PEM and inventory, etc.).

## OpenNebula Deployment Workflow

1. Review custom roles and hooks (`roles/one-driver`, `playbooks/scaleway.yml`).
2. Deploy the base OpenNebula stack (frontend, KVM nodes, shared configs):

   ```bash
   make deployment
   ```

3. Apply Scaleway-specific driver hooks and Flexible IP sync (`specifics` target invokes the `one-driver` role on frontend + nodes using the Hatch environment):

   ```bash
   make specifics
   ```

4. Run the validation suite:

   ```bash
   make validation
   ```

Each step is re-runnable; Ansible plays are idempotent and the Flexible IP hooks now cope with multi-NIC VMs (commit `a165376`).

## Validation Suite

The defaults in `inventory/group_vars/all.yml` enable:

- Core service health checks (`oned`, `gate`, `flow`, `fireedge`).
- Storage benchmark VM instantiation on `pub3`.
- Network benchmark between all hypervisors (iperf, ping).
- Connectivity matrix across hosts and `brvmtovm`.
- Marketplace VM deploy & smoke tests (Alpine Linux 3.21 template, optional VNET creation).

Disable tests by setting the corresponding `validation.run_*` flag to `false`. Validation output is saved under `/tmp/cloud_verification_report.html` (and other paths documented in the file).

## Troubleshooting & Known Issues

- **Flexible IP attach/detach:** `roles/one-driver/templates/vnm/bridge/{pre,clean}.d` hooks log verbosely to `/var/log/vnm/scw-flexip-pre.log` (attach) and `/var/log/vnm/scw-flexip-clean.log` (detach). Inspect those files when a driver action stalls—the logs capture every API call/response. Recent fixes (`4399aed`, `a165376`) ensure bridges are cleaned when VMs mix public & private NICs. Re-run `make specifics` after updating scripts so hosts download the latest hooks.
- **Ubuntu gateway for Flexible IPs:** When a Flexible IP lives outside the VM gateway netmask, Ubuntu does not auto-create the route after attaching the public NIC, so outbound traffic stalls. To persist the fix, drop a small netplan file and apply it (the alternative `ip route add` command disappears after reboot):

  ```yaml
  # /etc/netplan/99-flexip-route.yaml
  network:
    version: 2
    renderer: networkd
    ethernets:
      eth0:
        routes:
          - to: "62.210.0.1/32"
            via: 0.0.0.0
  ```

  Apply it with `sudo netplan apply`. The `ETH0_ROUTES` context setting remains broken by [OpenNebula/one-apps#284](https://github.com/OpenNebula/one-apps/issues/284) (VNET-independent `ROUTES`) and [OpenNebula/one#7348](https://github.com/OpenNebula/one/issues/7348) (`ETHx_ROUTES`), so codifying the route via netplan is the only reliable workaround today.
- **Host synchronization:** The role runs `onehost sync --force` for each registered host. Inspect Ansible output if Sync fails; hosts remain operational but may use outdated hooks.
- **Networking drift:** Re-apply module `004.opennebula_instances_net` or netplan templates if manual edits break VLAN alt-names or `brvmtovm` routes.
- **Credentials:** Missing Flexible IP token (`scw_flexible_ip_token`) or project ID causes the driver role to abort early via assertions.

## CI/CD Roadmap

`deployment_guide.md#7-cicd-pipeline-wip` outlines a GitHub Actions pipeline (WIP) that would:

1. Validate inputs (tokens, CIDRs, host IPs).
2. Run `tofu init/plan`.
3. Require manual approval for `tofu apply`.
4. Configure Ansible, then manually trigger `one-deploy-validation`, `one-deploy`, and eventual `tofu destroy`.

A reference Mermaid diagram is provided in the guide for future automation work.

## Extending the Cloud

To onboard a new hypervisor:

1. Rerun the provisioning modules (especially `003` and `004`) with an increased `TF_VAR_worker_count`.
2. Regenerate inventories (`005`) and verify SSH access.
3. Apply `make deployment` followed by `make specifics` so hooks and Flexible IP metadata land on the new host.
4. Re-run validation to ensure the additional capacity integrates cleanly.

For deeper background, diagrams, and step-by-step screenshots, consult [deployment_guide.md](./deployment_guide.md).
