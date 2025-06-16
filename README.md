# Template for OpenNebula integration with a Cloud Provider

Deployment and configuration specific to Cloud Provider. This repo is extends on the [one-deploy-validation](https://github.com/OpenNebula/one-deploy-validation).

> [!IMPORTANT]
> <div style="background-color:rgb(251, 188, 148); border-left: 4px solid #0366d6; padding: 1em;">
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
> 1. Add the submodule to the repository:
> 
>    ```shell
>    git submodule add git@github.com:OpenNebula/one-deploy-validation.git submodule-one-deploy-validation
>    ```
> 
> 1. The repository is ready to start working on the deployment values of OpenNebula, specific to the new Cloud Provider. Replace all "<<TBA>>" occurances:
> 
>    ```shell
>    grep -nR "<<TBA>>" .
>    ```
>
> 1. Update the README.md with link to the infrastructure provisions guide, that provides the starting point for this repo's steps. Update the table of essential parameters in the README.md to match the provisioned infrastructure and facilitate easy extraction of the parameters by following the same variable names.
> 
> 1. Implement the specific automations required on the cloud providers infrastructure to make OpenNebula fully functional (public IP routing, platform-specific configurations, etc.), as tested by the verification steps.
> 
> </div>

## Requirements

> [!NOTE]
> If Makefile is used then it will create python virtual environments using `hatch` (on demand).

1. Install `hatch`

   ```shell
   pip install hatch
   ```

1. Initialize the dependent `one-deploy-validation` submodule

   ```shell
   git submodule update --init
   ```

1. Install the `opennebula.deploy` collection with dependencies using the submodule's tooling:

   ```shell
   make submodule-requirements
   ```

## Infrastructure provisioning

A detailed guide to provision the required reference infrastructure is published in <span style="background-color: #fff3cd; padding: 2px 4px; border-radius: 2px;">ADD LINK TO THE GUIDE HERE</span>.
Follow the provisioning steps and the detailed guide on how to extract the essential parameters needed to proceed with the OpenNebula deployment.

## Customize the essential parameters

Update the `inventory` values to match the provisioned infrastructure, as described in the above referenced deployment guide. The table below shows the essential parameters that must be updated.

| Description                                 | Variable Names                      | Files/Location                                      |
|---------------------------------------------|-------------------------------------|-----------------------------------------------------|
| Frontend Host IP                            | `ansible_host`                      | `inventory/*.yml`    | 
| KVM Host IPs                            | `ansible_host`                      | `inventory/*.yml`     | 
| VXLAN PHYDEV                                 | `vn.vxlan.template.PHYDEV`          | `inventory/*.yml`                               | 
| pubridge PHYDEV                              | `vn.pubridge.template.PHYDEV`       | `inventory/*.yml`                               | 
| VMs Public IP Range                        | `vn.pubridge.template.AR.IP`, `vn.pubridge.template.AR.SIZE` | `inventory/*.yml`           | 
| <span style="background-color: #fff3cd; padding: 2px 4px; border-radius: 2px;"> Cloud Provider's params </span> | <span style="background-color: #fff3cd; padding: 2px 4px; border-radius: 2px;"> Name of variable </span> | <span style="background-color: #fff3cd; padding: 2px 4px; border-radius: 2px;"> Affected files </span> |.

## Inventory/Execution

> [!NOTE]
> It's exactly the same as with `one-deploy`.

1. Inventories are kept in the `./inventory/` directory.

1. Some specific make targets for deployment and verification are exposed from the submodule. To deploy with the default inventory file, using the submodule's tooling:

   ```shell
   make main
   ```

1. Launch the specific automations that cover the gap from an out-of-the-box OpenNebula deployment, to make it fully operational on the cloud provider's infrastructure:

   ```shell
   make specifics
   ```

1. To verify the deployment using the configurations in the default inventory file:

   ```shell
   make verification
   ```

For more information about the submodule's tooling, refer to its [README.md](https://github.com/OpenNebula/one-deploy-validation/blob/master/README.md) and for detailed documentation on the deployment automation refer to the [one-deploy repo](https://github.com/OpenNebula/one-deploy).


