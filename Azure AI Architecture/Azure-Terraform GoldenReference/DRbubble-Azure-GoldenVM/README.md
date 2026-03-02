>Refer to https://confluence.sys.cigna.com/display/CLOUD/Terraform+Module+Standards for Terraform module development standards and guidelines.

>Refer to https://wbassler23.medium.com/securing-secrets-for-your-iac-using-jenkins-terraform-and-ansible-vault-7009e0a7eb32 for secure method of handling secrets required by this module

# Azure Golden VM

## Overview

This Terraform module will deploy a Cigna standard Virtual Machine. It creates the following resources:

  - One or more network interfaces 
  - One or more IP addresses
  - Virtual Machine
  - OS Disk
  - One or more data disks attached to the VM

## Dependencies

- A resource Group must exist
- Virtual Network with subnet must exist
- Azure Disk Encryption Set with Customer Managed Key must exist in the same region that the VM will be created in (Azure Key Vault is required to support the encryption set)
- Terraform version 0.13 or newer is required for this module
- If deploying Ubuntu, you must accept the CIS license (this only needs to be done one time in a subscription)
    - az vm image terms accept --offer cis-ubuntu --plan cis-ubuntulinux2004-stig-gen1 --publisher center-for-internet-security-inc

## Important requirement for calling module

The calling module must include the following in the provider blocks:

1) Terraform block must include configuration_aliases section as shown in below example:

    terraform {
      required_version = ">= 0.13"
      required_providers {
        azurerm = {
          source                = "hashicorp/azurerm"
          version               = ">= 2.0"
          configuration_aliases = [azurerm.sig]
        }
      }
    }

2) An additional alias provider block must be added, as follows:

    provider "azurerm" {
      #Subscription holding Shared Image Gallery
      alias           = "sig"
      subscription_id = "9f7af41c-8074-4bc0-8cea-09b846ffc3f7"
      features {}
    }

## Inputs

### REQUIRED:

| Name | Description | Type | 
|------|-------------|------|
| resource_group_name | Resource group to deploy into | string |
| name | Desired VM name | string |
| required_tags | Required Cigna tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0) | object({AssetOwner = string, CostCenter = string, ServiceNowBA = string, ServiceNowAS = string, SecurityReviewID = string, ClaritySubProjectID = string}) |
| required_data_tags | Required Cigna data tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0) | object({ClaritySubProjectID = string, DataSubjectArea = string, ComplianceDataCategory = string, DataClassification = string, BusinessEntity = string, LineOfBusiness = string}) |
| os_type | Linux or Windows | string |
| size | VM size (see https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-general) | string |
| image_name | Name of the image in the Shared Image Gallery (SIG) | string |
| nics | One or more vNics to create for VM | list of objects [{subnet_name = string, virtual_network_name = string}]}] |
| disk_encryption_set_id | ID of encryption set to use for disk encryption | string |
| admin_username | Administrator user name | string |
| admin_password | Administrator password for Windows, or public SSH key for Linux (pass in securely) | string |

### OPTIONAL:

>Include all configuration variables that are not required, along with default value

| Name | Description | Type | Default |
|------|-------------|------|---------|
| location | Region to deploy in | string | "EastUS" |
| zone | Availability Zone to deploy in (1-3), or null if AZ support not needed | null |
| optional_tags | Optional Cigna standard tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0) | map(string) | {} |
| optional_data_tags | Optional Cigna data tags (reference https://confluence.sys.cigna.com/display/CLOUD/Cloud+Tagging+Requirements+V2.0) | map(string) | {} |
| plan_publisher | The plan publisher for licensing of image to deploy | string | center-for-internet-security-inc |
| plan_offer | The 'plan offer' or 'plan name' for the shared image licensing | string | cis-ubuntu-linux-2004-stig |
| plan_sku | The 'plan sku' or 'plan product' for the image licensing | string | cis-ubuntu-linux-2004-stig |
| OS_storage_account_type | OS Disk storage tier (Standard_LRS, StandardSSD_LRS, Premium_LRS) | string | StandardSSD_LRS |
| ultra_ssd_enabled | Set to true to enable Ultra SSD drive support | bool | false |
| data_disks | Data disks to create | list of objects list [{name = string, disk_size_gb = string, storage_account_type = string, lun = string, caching = string}] | [] |
| OS_caching | Type of caching for OS disk (None, ReadOnly or ReadWrite) | string | ReadWrite |
| custom_data | Base64-Encoded Custom Data for this Virtual Machine | string | null |
| priority | Must be either either 'Regular' or 'Spot' | string | Regular |


### OVERRIDE:

>This is an optional section -- consider using if appropriate, or delete if it does not apply to your module

*The default value for these variables should be accepted in production environments, these are provided only to accommodate dev/test or unanticipated corner cases*

| Name | Description | Type | Default |
|------|-------------|------|---------|
| image_version | Version to deploy | string | "latest" |
| private_ip_address_allocation | Dynamic or Static | string | Dynamic |
| enable_automatic_updates | If true automatically update OS | bool | false |
| enable_accelerated_networking | Accelerated networking enabled if true | bool | true |
| storage_account_uri | URI pointing to root-level storage for diagnostics -- leave null to use Managed Storage account | string | null |
| encryption_at_host_enabled | Enable encryption of all drives (including temp disks), and cache | bool | true |

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| vm_id | ID of VM created | no |
| vm_identity | Identity block containing principal_id and tenant_id of managed service identity for the VM | yes |

## Usage

    module "Azure-GoldenVMModule" {
      source = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenVM.git"

    resource_group_name = "CriblDemo-rg"
    name = "CriblDemo01-vm"
    required_tags = {
      AssetOwner = "james.brown@cigna.com"
      CostCenter = "0004076"
      ServiceNowBA = "0000000"
      ServiceNowAS = "0000000"
      SecurityReviewID = "0000000"
    }
    required_data_tags = {
      DataSubjectArea        = "IT"
      ComplianceDataCategory = "PCI"
      DataClassification     = "Confidential"
      BusinessEntity         = "COE"
      LineOfBusiness         = "Automation"

    }
    nics = [{
                subnet_name = "default-snet"
                virtual_network_name = "default_routable-vnet"
          }]
    os_type = "Linux"
    image_name = "CriblImageDefinition"
    size = "Standard_D4as_v4"
    admin_username = "azadmin"
    source_image = {
          version = "latest"
    }
    disk_encryption_set_id = "/subscriptions/e21aa9b2-7d66-4aa3-898d-503686e49ff6/resourceGroups/michael_s-rg/providers/Microsoft.Compute/diskEncryptionSets/ssevms-des"
    data_disks = [{
          name = "01"
          disk_size_gb = "50"
          storage_account_type = "Standard_LRS"
          lun = "10"
          caching = "ReadWrite"
        }]

## Submodules

- n/a

## Additional Information
Password or SSH key needs to be passed in securely. Reference https://learn.hashicorp.com/tutorials/terraform/sensitive-variables for information on sensitive variables.

## Links

- Service Page https://confluence.sys.cigna.com/pages/viewpage.action?pageId=483889530
- Examples https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-Golden-VM-Module/examples/
