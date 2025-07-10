> [!IMPORTANT]
>  
> ## First time template repo setup -- TO BE REMOVED FROM THE TEMPLATE
> 
> 1. Rename all occurances of "cloud-provider" to the new Cloud Provider "new-cp":
> 
>    ```shell
>    new_cp_name=new-cp
>    find . -type f ! -name 'README.md' -not -path "./.git/*" -not -path "./submodule-one-deploy-validation/*" -exec sed -i 's/cloud-provider/'$new_cp_name'/g' {} +
>    mv inventory/cloud-provider.yml inventory/$new_cp_name.yml
>    mv playbooks/cloud-provider.yml playbooks/$new_cp_name.yml
>    ```
> 
> 1. The repository is ready to start working on the deployment values of OpenNebula, specific to the new Cloud Provider. Replace all `<<TBA>>` occurances:
> 
>    ```shell
>    grep -nR "<<TBA>>" .
>    ```
>
> 1. Update the README.md with link to the infrastructure provisions guide, that provides the starting point for this repo's steps. Update the table of required parameters in the README.md to match the provisioned infrastructure and facilitate easy extraction of the parameters by following the same variable names. Upload the logo of the cloud provider and make any necessary adjustments.
> 
> 1. Implement the specific automations required on the cloud providers infrastructure to make OpenNebula fully functional (public IP routing, platform-specific configurations, etc.), as tested by the validation steps.
> 
>  1. Remove this note from the README.md
>

**TBA-cloud-provider**: logos of OpenNebula and the Cloud Provider

# Deploying OpenNebula as a Hosted Cloud on TBA-cloud-provider

This repository contains the needed code and documentation to perform an OpenNebula deployment and configuration as 
a Hosted Cloud on **TBA-cloud-provider** resources. It extends the [one-deploy-validation](https://github.com/OpenNebula/one-deploy-validation) repository, which is added as a git submodule.

- [Requirements](#requirements)
- [Infrastructure Provisioning](#infrastructure-provisioning)
- [Required Parameters](#required-parameters)
- [Deployment and Validation](#deployment-and-validation)

## Requirements

1. Install `hatch`

   ```shell
   pip install hatch
   ```

1. Initialize the dependent `one-deploy-validation` and `one-deploy` submodules

   ```shell
   git submodule update --init --remote --merge
   ```

1. Install the `opennebula.deploy` collection with dependencies using the submodule's tooling:

   ```shell
   make submodule-requirements
   ```

## Infrastructure Provisioning

A detailed guide to provision the required reference infrastructure is published in **[{ADD LINK TO THE GUIDE HERE}]()**.
Follow the provisioning steps and extract the requiremed parameters needed to proceed with the OpenNebula deployment.

## Required Parameters

Update the [inventory](./inventory/) values to match the provisioned infrastructure.

| Description                                 | Variable Names                      | Files/Location                                      |
|---------------------------------------------|-------------------------------------|-----------------------------------------------------|
| Frontend Host IP                            | `ansible_host`                      | [inventory/*.yml](./inventory/)    | 
| KVM Host IPs                            | `ansible_host`                      | [inventory/*.yml](./inventory/)     | 
| VXLAN PHYDEV                                 | `vn.vxlan.template.PHYDEV`          | [inventory/*.yml](./inventory/)                               | 
| pubridge PHYDEV                              | `vn.pubridge.template.PHYDEV`       | [inventory/*.yml](./inventory/)                               | 
| VMs Public IP Range                        | `vn.pubridge.template.AR.IP`, `vn.pubridge.template.AR.SIZE` | [inventory/*.yml](./inventory/)           | 
| GUI password of `oneadmin`       | `one_pass` | [inventory/*.yml](./inventory/)           | 
|  **{Cloud Provider's params}** |  **{Name of variable}** |  **{Affected files}** |.

## Deployment and Validation

Use the provided Makefile commands to automate deployment and testing:

1. Review the [inventory](./inventory/), [playbooks](./playbooks/) and [roles](./roles/) directories, following Ansible design guidelines.

1. Deploy OpenNebula:

   ```shell
   make deployment
   ```

1. Configure the deployment for the specifics of the Cloud Provider:

   ```shell
   make specifics
   ```

1. Test the deployment:

   ```shell
   make validation
   ```

For more information about the submodule's tooling, refer to its [README.md](https://github.com/OpenNebula/one-deploy-validation/blob/master/README.md) and for detailed documentation on the deployment automation refer to the [one-deploy repo](https://github.com/OpenNebula/one-deploy).


