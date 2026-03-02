data "azurerm_client_config" "current" {}

module "GoldenWindowsWebApp" {
  #source = "../../../WindowsWebApp"
  source              = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenWebApp.git//LinuxWebApp?ref=3.2.0"
  name                = var.app_service_name
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  required_tags       = var.required_tags
  optional_tags       = var.optional_tags
  identity_type       = "SystemAssigned" 

  #Optional
  #health_check_path   = "/api/HealthCheck" #This example uses endpoint named HealthCheck when testing with code.

  #Include App Service Plan
  include_app_service_plan  = true
  app_service_plan_name     = format("%s%s", var.app_service_plan_name, "-asp")
  app_service_plan_sku_name = var.sku_name

  #Include App Insights and Log Analytics Workspace
  include_app_insights = true

  #Scaling
  #Set the scale settings to meet your requirements
  per_site_scaling_enabled         = true
  app_scale_limit                  = 4
  app_worker_count                 = 1 #If Zone redundancy is enabled in ASP, the worker_count should equal the number of zones in the selected region.
  pre_warmed_instance_count        = 2
  plan_worker_count                = 1
  runtime_scale_monitoring_enabled = false

  #Configuration
  always_on         = true
  use_32_bit_worker = false

  #Use this to deploy docker container to a Production slot
/*   use_docker = true
  docker = {
          registry_url       = "https://tbacrpoc.azurecr.io"  #ACR URL
          image_name         = "worldtripclient:ch1"  #Repository name and tag
  } */

  client_certificate_enabled        = true
  client_certificate_mode           = "Optional"

  #Optional
  sticky_settings_app_setting_names = ["DRYRUN"]

  app_settings = {
    # User settings
    TEST1SETTING = "test1"
    TEST2SETTING = "test2"
  }
  allowed_origins = ["https://portal.azure.com"]

  #Networking
  public_network_access_enabled = false
  vnet_route_all_enabled       = true
  virtual_network_subnet_id    = var.virtualnetworksubnetid
  private_endpoint_subnet_id   = var.pe_subnet_id


  #Slots
  include_web_app_slot = true
  web_app_slot = {
    name                       = "staging"
    private_endpoint_subnet_id = var.pe_subnet_id
    use_docker                 = true
    registry_url               = "https://mcr.microsoft.com"  #ACR URL
    image_name                 = "azure-app-service/windows/parkingpage:latest"          #Repository name and tag

    app_settings = {
      TEST1SETTING = "test1"
      TEST2SETTING = "test2"
      #DOCKER_SKIP_IMAGE_VALIDATION = "true"
    }
  }


  #Monitoring and Alerts
  webapp_diagnostics_settings     = var.web_diag
  
  #Alerts
  #If no alerts are to be included set this variable to false
  include_alerts            = false 

  #By default, alerts will be added and this variable must be set to a valid alarm funnel environment
  alarm_funnel_environment = "dev"
  alarm_funnel_app_name    = "my-alarm-funnel-app-name" #Name registered in alarm funnel yaml file. Overrides var.name variable.
  
  #Set this variable to true to include an alert action group
  include_alert_action_group = false
  #This variable is required when including an alert action group
  alert_email_addresses = ["troy.braman@evicore.com"]

  #Logs
  #Set the log requirements to meet your requirements
  logs = {
    detailed_error_messages = true
    application_logs = {
      file_system_level = "Verbose"
    }
    http_logs = {
      file_system = {
        retention_in_days = 90
        retention_in_mb   = 35
      }
    }

  }
}


#Grant ACRPull for web app and web app slot
resource "azurerm_role_assignment" "ra" {
  depends_on          = [module.GoldenWindowsWebApp]
  principal_id         = module.GoldenWindowsWebApp.app_identity
  role_definition_name = "AcrPull"
  scope                = "/subscriptions/75dbc8c6-6364-4eb1-91c1-3400a4010fb4/resourceGroups/tb-acr-poc/providers/Microsoft.ContainerRegistry/registries/tbacrpoc"
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "ra_slot" {
  depends_on          = [module.GoldenWindowsWebApp]
  principal_id         = module.GoldenWindowsWebApp.app_slot_identity
  role_definition_name = "AcrPull"
  scope                = "/subscriptions/75dbc8c6-6364-4eb1-91c1-3400a4010fb4/resourceGroups/tb-acr-poc/providers/Microsoft.ContainerRegistry/registries/tbacrpoc"
  principal_type       = "ServicePrincipal"
}

#Using azapi provider to set the vnetImagePullEnabled property since azurerm provider does not currently support enabling this property.
resource "azapi_update_resource" "app_vnet_container_pull_routing" {
  depends_on  = [module.GoldenWindowsWebApp]
  resource_id = module.GoldenWindowsWebApp.app_id
  type        = "Microsoft.Web/sites@2022-09-01"
  body = {
    properties = {
      vnetImagePullEnabled =  true
    }
  }
}
resource "azapi_update_resource" "app_slot_vnet_container_pull_routing" {
  depends_on  = [module.GoldenWindowsWebApp]
  resource_id = module.GoldenWindowsWebApp.app_slot_id
  type        = "Microsoft.Web/sites/slots@2022-09-01"
  body = {
    properties = {
      vnetImagePullEnabled =  true
    }
  }
}




