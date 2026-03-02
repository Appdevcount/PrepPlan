data "azurerm_client_config" "current" {}

module "GoldenLinuxWebApp" {

  #source = "../../../LinuxWebApp"
  source              = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenWebApp.git//LinuxWebApp?ref=3.2.0"
  name                = "gmtestlinuxwa130"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  required_tags       = var.required_tags
  optional_tags       = var.optional_tags
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
  plan_worker_count                = 3
  runtime_scale_monitoring_enabled = false

  #Configuration
  always_on         = true
  use_32_bit_worker = false
  use_dotnet        = true
  dotnet_version    = "8.0"
  #use_dotnetcore                    = true
  #dotnetcore_version                = "v4.0"

  client_certificate_enabled        = true
  client_certificate_mode           = "Optional"

  #Optional
  sticky_settings_app_setting_names = ["DRYRUN"]

  app_settings = {
    # User settings
    #APPINSIGHTS_INSTRUMENTATIONKEY = "sdfgfdgtrgrt"
    TEST1SETTING = "test1"
    TEST2SETTING = "test2"
  }
  allowed_origins = ["https://portal.azure.com"]

  #Networking
  public_network_access_enabled = false
  vnet_route_all_enabled       = true
  vnet_image_pull_enabled      = true
  virtual_network_subnet_id    = var.virtualnetworksubnetid
  private_endpoint_subnet_id   = var.pe_subnet_id
  #Required if public_network_access_enabled = true
  #ip_restriction               = var.ip_restriction
  #scm_ip_restriction           = var.scm_ip_restriction


  #Slots
  include_web_app_slot = true
  web_app_slot = {
    name                       = "staging"
    #auto_swap_slot_name        = "production"
    private_endpoint_subnet_id = var.pe_subnet_id
    #Required if public_network_access_enabled = true
    #ip_restriction             = var.ip_restriction
    #scm_ip_restriction         = var.scm_ip_restriction
    app_settings = {
      DRYRUN       = true
      TEST1SETTING = "test3"
      TEST2SETTING = "test4"
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

  #Sample on how to override alert values. This is an optional variable with several optional settings.
  #It is only needed if you need to override any default values, otherwise this variable does not have to be used.
  #NOTE: It is not neccessary to override all options. Only the arguments that require an override need to be provided.
  #      See the Option Input section in the README.md file.
/*   alerts = {

    #webapp_stopped = { 
       #alarm_funnel_severity = "CRITICAL"
    #  }

  } */

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
