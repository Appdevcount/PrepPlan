terraform {
  required_version = ">= 1.4.4"
  required_providers {
    azurerm = ">= 3.35.0"
    azuread = ">= 1.0"
  }
}
/* 
terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.35.0"
    }
  }
} */