# Zscaler Nanolog Streaming Services Bootstrap Module Example

This Terraform example uses the [Zscaler Nanolog Streaming Services Bootstrap module](../../modules/bootstrap) to deploy a Storage Account and the dependencies required
to [bootstrap a NSS VM in Azure](https://help.zscaler.com/zia/nss-deployment-guide-microsoft-azure).

The following resources will be deployed when using the provided example:
* 1 [Resource Group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group).
* 1 [Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview).
* 1 [File Share](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction#:~:text=Azure%20Files%20offers%20fully%20managed,cloud%20or%20on%2Dpremises%20deployments).
* 1 [Automation Account](https://docs.microsoft.com/en-us/azure/automation/overview).

## Usage

Create a `terraform.tfvars` file and copy the content of `examples.tfvars` into it, adjust the variables (in particular the `storage_account_name` should be unique).

```sh
terraform init
terraform apply
terraform output -json
```

## Cleanup

```sh
terraform destroy
```
