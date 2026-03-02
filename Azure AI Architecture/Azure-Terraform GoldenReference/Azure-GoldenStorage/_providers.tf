terraform {
  required_version = ">= 1.4.4"
  required_providers {
    azurerm = ">= 3.87.0" # Minimum required for RASS
    azuread = ">= 1.0"
  }
}