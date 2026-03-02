/*
Note:
Terraform uses Shared Key Authorization to provision Storage Containers, Blobs and other items - 
when Shared Key Access is disabled, you will need to enable the storage_use_azuread flag in the Provider block to use Azure AD for authentication, 
however not all Azure Storage services support Active Directory authentication.
The Files & Table Storage API's do not support authenticating via AzureAD and will continue to use a SharedKey to access the API's.
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
*/
/* provider "azurerm" {
  # Configuration options
  features {}
    storage_use_azuread = !var.shared_access_key_enabled
} */

