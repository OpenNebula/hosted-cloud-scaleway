

<img width="1200" height="627" alt="image" src="https://github.com/user-attachments/assets/f692ad33-f205-4d47-9e48-938c2d81326c" />

![opennebula_cloud_logo_white_bg](https://github.com/user-attachments/assets/130bcaad-6b90-4adc-9971-dcc93c0a1fe5)  

# Deployment Guide

## 🏗️ Target OpenNebula Architecture

This section provides a detailed description of the target architecture based on OpenNebula, specifically deployed on Scaleway Elastic Metal instances. The architecture is designed to leverage the robust capabilities of bare-metal servers to deliver a comprehensive Infrastructure-as-a-Service (IaaS) solution.

### Objectives

The primary objective is to deliver a full-fledged IaaS infrastructure on bare-metal servers, ensuring high performance, reliability, and scalability.

### Core Components

**OpenNebula Front-end (with KVM):**

- **Functionality:** Manages the entire lifecycle of virtual machines (VMs), including networking and storage. It also provides the OpenNebula frontend interface for user interaction.
- **Additional Role:** Runs local virtual machines, effectively acting as a compute node within the infrastructure.

**Hypervisor Nodes:**

- **Instance Type:** EM-A610R-NVMe instances running KVM.
- **Networking:** Connected to a private network for secure internal communication.
- **Public Access:** Can be attached to a Public IP to provide external access to VMs.

### Storage

- **Local Storage:** Each node is equipped with local NVMe SSDs to ensure high-speed data access and storage performance.
- **Capacity:** 2× NVMe 960 GB local storage per node, providing ample space for VM images and data.

### Networking

- **Virtual Network:** Utilizes Private Networks within a Virtual Private Cloud (VPC) to ensure secure and isolated communication between instances.
- **Public Gateway:** For high traffic scenarios, a Public Gateway is the preferred method. However, for initial deployment and Minimum Viable Product (MVP) phases, Public IPs can be directly attached to instances via Network Interface Cards (NIC).

![Networking Diagram](https://github.com/user-attachments/assets/bc13e49d-8c84-4055-80a5-29278e3375c1)

### High-Level Diagram

The high-level diagram below illustrates the overall architecture, including the interaction between the OpenNebula Front-end, hypervisor nodes, and networking components.

![High-Level Diagram](https://github.com/user-attachments/assets/c17945c5-d3f5-4e08-a7c1-ff42bba3365e)

### Hardware Specification

The hardware specifications for the Elastic Metal Instances – EM-A610R-NVMe are as follows:

| Role | Instance Type | CPU | RAM | Disks | KVM | Count | Bandwidth |
|------|---------------|-----|-----|-------|-----|-------|-----------|
| Front-end + KVM | EM-A610R-NVMe | AMD Ryzen PRO 3600 (6C / 12T) | 16 GB | 2× NVMe 960 GB | Yes | 1 | Up to 1 Gbps |
| Hypervisor(s) | EM-A610R-NVMe | AMD Ryzen PRO 3600 (6C / 12T) | 16 GB | 2× NVMe 960 GB | Yes | 1 to any | Up to 1 Gbps |

This setup ensures that the infrastructure is capable of handling a wide range of workloads, providing both the computational power and storage capacity necessary for demanding applications.

### Provisioning Strategies

#### Prerequisites and Capabilities

**Prerequisites:**
- Ubuntu 22.04 or 24.04 with Netplan version 0.105 or higher.
- Passwordless SSH login as root from the Front-end node to the Hypervisor nodes.
- The user performing the installation must have the ability to sudo to the root account.
- A range of free IP addresses available on the same network connecting the Front-end and Hypervisors.

**Capabilities:**
- Utilization of OneDeploy roles and tags.
- Integration of the OneHook driver in Ansible.

#### Initial Setup

Terraform is used to create instances and networks, and it generates inventories for Ansible.

#### Setting Up OpenNebula

For more details, refer to the [OpenNebula Documentation](https://docs.opennebula.io/7.0/software/installation_process/automatic_installation_with_onedeploy/).

![OpenNebula Setup](https://github.com/user-attachments/assets/ae7c4d9e-4384-4dbd-8fb2-165e743e17e4)

Once the inventories are supplied, the setup can proceed using the `one-deploy-validation` and `one-deploy` submodules, which provide generic tasks to configure OpenNebula. This process relies on previously generated inventories and requires SSH and sudoers to be defined.

##### Runtime Hooks

Hooks must be provided to ensure runtime operations for OpenNebula. These hooks facilitate the hotplugging of public Network Interface Cards (NICs) using a driver specific to each cloud provider. For detailed specifications, refer to the [Hook Driver Documentation](https://docs.opennebula.io/7.0/product/integration_references/system_interfaces/hook_driver/).

In this particular case, the hook can be provided using an Ansible role for Scaleway. For more information, see the [Scaleway Guide](https://docs.ansible.com/ansible/latest/collections/community/general/docsite/guide_scaleway.html#ansible-collections-community-general-docsite-guide-scaleway).

![Scaleway Hook](https://github.com/user-attachments/assets/8fd87b07-1345-4d0c-a63a-5a7dd9ce86dc)

