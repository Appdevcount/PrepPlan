data "azurerm_client_config" "current" {}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                       = "${var.resource_group_name}-log"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  internet_query_enabled     = true
  internet_ingestion_enabled = true
  tags                       = var.required_tags
}

resource "azurerm_application_insights" "appinsights" {

  name                                = "${var.app_service_plan_name}-ai"
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  workspace_id                        = azurerm_log_analytics_workspace.workspace.id
  application_type                    = "web"
  internet_ingestion_enabled          = true
  internet_query_enabled              = true
  local_authentication_disabled       = false
  force_customer_storage_for_profiler = false
  sampling_percentage                 = 0
  tags                                = var.required_tags
}

resource "azurerm_service_plan" "asp" {
  name                         = var.app_service_plan_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  os_type                      = "Windows"
  sku_name                     = local.sku_name
  worker_count                 = 3
  per_site_scaling_enabled     = false
  zone_balancing_enabled       = false
  tags                         = var.required_tags
}

module "GoldenWindowWebApp" {
    depends_on = [azurerm_service_plan.asp]

    #source                            = "../../../WindowsWebApp"
    source                            = "git::https://eviCoreDev@dev.azure.com/eviCoreDev/Reusable%20Code/_git/DRbubble-Azure-GoldenWebApp.git//WindowsWebApp?ref=3.2.0"

    for_each                          = var.webapps_to_create
    name                              = each.key
    #name                              = "gmtestwindowwa104"
    resource_group_name               = var.resource_group_name
    location                          = var.location
    environment                       = var.environment
    required_tags                     = var.required_tags
    optional_tags                     = var.optional_tags
    #health_check_path                 = "/api/HealthCheck" #This example uses endpoint named HealthCheck when testing with code.
    
    #Include App Service Plan
    #include_app_service_plan          = true
    #app_service_plan_name             = local.asp_name
    service_plan_id                   = azurerm_service_plan.asp.id
    app_service_plan_sku_name         = local.sku_name 

    #Include App Insights and Log Analytics Workspace
    include_app_insights              = true
    
    #Scaling
    per_site_scaling_enabled         = true
    app_scale_limit                   = 4
    app_worker_count                  = 1 #If Zone redundancy is enabled in ASP, the worker_count should equal the number of zones in the selected region.
    pre_warmed_instance_count         = 2
    plan_worker_count                 = 3 
    runtime_scale_monitoring_enabled  = false 

    #Configuration
    always_on                         = true
    use_32_bit_worker                 = false
    current_stack                     = "dotnet"
    use_dotnet                        = true
    dotnet_version                    = "v8.0"
    #use_dotnetcore                    = true
    #dotnetcore_version                = "v4.0"

    client_certificate_enabled        = true
    client_certificate_mode           = "Optional"
    sticky_settings_app_setting_names = ["DRYRUN"]
 #   app_settings                      = {
 #                                         # User settings
 #                                         #APPINSIGHTS_INSTRUMENTATIONKEY = "sdfgfdgtrgrt"
 #                                         TEST1SETTING = "test1"
 #                                         TEST2SETTING = "test2"
 #                                       }  
    app_settings                      = each.value.app_settings

    allowed_origins                   = ["https://portal.azure.com"]
    
    #Networking
    vnet_route_all_enabled            = true
    virtual_network_subnet_id         = var.virtualnetworksubnetid
    private_endpoint_subnet_id        = local.pe_subnet_id
   # ip_restriction                    = var.ip_restriction
   # scm_ip_restriction                = var.scm_ip_restriction


    #Slots
    include_web_app_slot          = true  
    web_app_slot                  = {
                                           name                       = "staging"
                                           #auto_swap_slot_name        = "production"
                                           private_endpoint_subnet_id = local.pe_subnet_id 
                                           ip_restriction             = var.ip_restriction
                                           scm_ip_restriction         = var.scm_ip_restriction
                                           app_settings = {
                                                           DRYRUN = true
                                                           TEST1SETTING = "test1"
                                                           TEST2SETTING = "test2"
                                                           }     
                                         }   


                                                       
    #Include Monitoring and Alerts
    webapp_diagnostics_settings     = local.web_diag   
  #Alerts
  #If no alerts are to be included set this variable to false
  #include_alerts            = false 

  #By default, alerts will be added and this variable must be set to a valid alarm funnel environment
  alarm_funnel_environment = "dev"

  #Set this variable to true to include an alert action group
  #include_alert_action_group = true
  #This variable is required when including an alert action group
  #alert_email_addresses = ["EMAIL ADDRESS"]
  alarm_funnel_app_name = "my-alarm-funnel-app-name" #Name registered in alarm funnel yaml file. Overrides var.name variable.
  
  #Sample on how to override alert values. This is an optional variable with several optional settings.
  #It is only needed if you need to override any default values, otherwise this variable does not have to be used.
  #NOTE: It is not neccessary to override all options. Only the arguments that require an ovrride need to be provided.
  #      See the Option Input section in the README.md file.
/*   alerts = {

    #webapp_stopped = { 
       #alarm_funnel_severity = "CRITICAL"
    #  }

  } */

    #Logs
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
