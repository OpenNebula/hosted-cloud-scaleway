# Scaleway role for OpenNebula driver

This role installs a custom OpenNebula IPAM driver that serves network
information for Scaleway Flexible IPs at allocation time. The script is written
in Bash and talks to the Scaleway REST API with `curl`, eliminating the need
for the `scw` CLI or Ruby on the front-end host.

## What the driver does

* provides the full IPAM lifecycle (`register_address_range`,
  `allocate_address`, `get_address`, `free_address`,
  `unregister_address_range`) so OpenNebula coordinates with Scaleway's
  Flexible IP API,
* creates a new Flexible IP on demand (using the configured Scaleway project)
  whenever OpenNebula allocates an address,
* generates a virtual MAC (`kvm` by default) when the newly created Flexible IP
  does not already have one,
* persists the reservation in `{{ one_driver_state_file }}` to avoid race
  conditions and to release the same Flexible IP later,
* returns the expected `IP`, `MAC`, `NETWORK_*`, `GATEWAY`, and `DNS` pairs to
  OpenNebula so that VMs get the full configuration via context/cloud-init,
* deploys bridge pre/clean hooks that call the Flexible IP API to attach the
  lease to the current Elastic Metal server during `pre`, and detach it during
  `clean`,
* synchronizes every OpenNebula host afterwards with `onehost sync --force`
  (only when the OpenNebula frontend files are present on that host).

The address range definition can stay minimal, for example:

```
AR = [
  TYPE = "IP4",
  IP   = "130.56.23.17",
  MAC  = "50:20:20:20:20:21",
  SIZE = "1"
]
```

The associated virtual network must set `IPAM_MAD = "scw-flexip"` (the role
adds this MAD to `oned.conf`). No additional attributes are required on the AR.

## Role variables

| Variable | Description |
|----------|-------------|
| `one_driver_flexible_ip_token` | **Required.** Scaleway API key with `instance:read` permissions. Usually sourced from the generated inventory variable `scw_flexible_ip_token`. |
| `one_driver_zone` | Scaleway zone (defaults to `fr-par-1`). |
| `one_driver_network_mask` | Netmask reported back to OpenNebula (`255.255.255.255` by default). |
| `one_driver_gateway` | Optional gateway used when the API response does not include one. |
| `one_driver_dns_servers` | Optional list of DNS resolvers returned with the lease. |
| `one_driver_token_path` | Path where the API token will be written (`/var/lib/one/.scw-flexip.token`). |
| `one_driver_project_id` | Scaleway project UUID used when creating Flexible IPs. |
| `one_driver_state_file` | JSON file storing current Flexible IP reservations. |
| `one_driver_mac_type` | Scaleway virtual MAC type requested when none exists (`kvm` by default). |
| `one_driver_vnm_bridge_dir` | Location of the bridge MAD hooks (`/var/lib/one/remotes/vnm/bridge`). |
| `one_driver_ipam_scripts` | List of IPAM action scripts deployed to the remotes. |

The defaults for these variables live in `defaults/main.yaml` and pull from
inventory variables emitted by `scw/005.opennebula_inventories`.

Each hypervisor host must expose its Scaleway Elastic Metal server UUID through
the inventory variable `scw_server_id`. The bridge hooks use this identifier
to call the Flexible IP attach/detach endpoints.

## IPAM scripts

OpenNebula executes the following helper scripts under
`/var/lib/one/remotes/ipam/{{ one_driver_ipam_name }}`:

- `register_address_range`
- `unregister_address_range`
- `allocate_address`
- `get_address`
- `free_address`

All of them import `common.py`, which implements token handling, reservation
state, and the Scaleway Flexible IP REST requests.

## Handlers

The role triggers an OpenNebula restart whenever the MAD stanza in
`/etc/one/oned.conf` is updated.

## References

* [OpenNebula - Network Driver Development](https://docs.opennebula.io/7.0/product/integration_references/infrastructure_drivers_development/)
* [Scaleway Flexible IP API](https://developers.scaleway.com/en/products/instance/api/) (Instance API, Flexible IP section)
