# Template for OpenNebula integration with a Cloud Provider

Deployment and configuration specific to Cloud Provider. This repo is extends on the [one-deploy-validation](https://github.com/OpenNebula/one-deploy-validation).

## First time template repo setup


1. Rename all occurances of "cloud-provider" to the new Cloud Provider "new-cp":

   ```shell
   new_cp_name=new-cp
   find . -type f ! -name 'README.md' -not -path "./.git/*" -not -path "./submodule-one-deploy-validation/*" -exec sed -i 's/cloud-provider/'$new_cp_name'/g' {} +
   mv inventory/cloud-provider.yml inventory/$new_cp_name.yml
   mv playbooks/cloud-provider.yml playbooks/$new_cp_name.yml
   ```

1. Add the submodule to the repository:

   ```shell
   git submodule add git@github.com:OpenNebula/one-deploy-validation.git submodule-one-deploy-validation
   ```

1. The repository is ready to start working on the deployment values of OpenNebula, specific to the new Cloud Provider. Replace all "<<TBA>>" occurances:

   ```shell
   grep -nR "<<TBA>>" .
   ```

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

A detailed guide to provision the required reference infrastructure MUST be provided.

## Inventory/Execution

> [!NOTE]
> It's exactly the same as with `one-deploy`.

1. Inventories are kept in the `./inventory/` directory.

1. Some specific make targets for deployment and verification are exposed from the submodule. To deploy with the default inventory file, using the submodule's tooling:

   ```shell
   make main
   ```

1. To verify the deployment using the configurations in the default inventory file:

   ```shell
   make verification
   ```

For more information about the submodule's tooling, refer to its [README.md](https://github.com/OpenNebula/one-deploy-validation/blob/master/README.md).

