# Azure-GoldenWebApp-Linux(3.2.0)

## Overview

ALWAYS RUN A TERRAFORM PLAN TO VERIFY IF A DESTROY WILL TAKE PLACE ESPECIALLY IF YOUR PIPELINE USES AUTO APPROVE ON A TERRAFORM APPLY WITHOUT FIRST VERIFING A TERRAFORM PLAN.

This Terraform module will deploy a Cigna\eviCore standard **Linux** Web App with the following optional resources:

* App Service Plan
* App Insights and Log Analytics Workspace
* Function App Slot
* FMEA Alerts

  * Includes Alarm Funnel connectivity

Tested with the following versions:

* Terraform: v1.9.5
* Azurerm: v4.37.0
* Azuread: v2.53.1

## Dependencies

* A VNET with Subnets for vnet integration, private endpoints and a private DNS zone must exist.
