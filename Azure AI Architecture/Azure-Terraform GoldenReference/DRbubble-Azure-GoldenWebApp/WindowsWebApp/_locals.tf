locals {


  add_action_group = var.include_alerts && (var.include_alert_action_group || var.external_action_group_id != null)
  use_external_action_group = var.external_action_group_id != null
  
  os_type = var.use_docker || var.web_app_slot.use_docker ? "WindowsContainer": "Windows"
  
  use_application_stack = var.use_docker || var.use_dotnet || var.use_dotnetcore || var.use_java || var.use_node || var.use_php || var.use_python

  valid_alarm_funnel_environments           = ["SANDBOX", "DEV", "TEST", "PROD"]
  valid_alarm_funnel_environments_string    = join(", ", local.valid_alarm_funnel_environments)
  valid_alarm_funnel_severity_levels        = ["INFO", "WARN", "CRITICAL"]
  valid_alarm_funnel_severity_levels_string = join(", ", local.valid_alarm_funnel_severity_levels)

  alarm_funnel_tenant = {
    "595de295-db43-4c19-8b50-183dfd4a3d06" = {
      "action_group_id" = "/subscriptions/4291f6cb-6acb-4857-8d9a-3510df28ce1d/resourceGroups/AlarmFunnel-rg/providers/microsoft.insights/actiongroups/AlarmFunnel-ag"
    }
    "791b26cb-3fdf-47c3-b85d-bd9f037e3e7f" = {
      "action_group_id" = "/subscriptions/9f7af41c-8074-4bc0-8cea-09b846ffc3f7/resourceGroups/Alarm-Funnel-prod-rg/providers/Microsoft.Insights/actiongroups/AlarmFunnel-ag"
    }
  }

  alarm_funnel = var.include_alerts && contains(local.valid_alarm_funnel_environments, upper(var.alarm_funnel_environment)) ? lookup(local.alarm_funnel_tenant, data.azurerm_client_config.current.tenant_id) : null

  ### git ref tag parsing ###
  is_relative_path = can(regex("\\.\\./", path.module))
  module_file      = local.is_relative_path ? null : jsondecode(file("${path.module}/../../modules.json"))
  module_key       = basename(dirname(path.module))
  module_source = (local.is_relative_path
    ? path.module
    : local.module_file.Modules[index(local.module_file.Modules.*.Key, local.module_key)]["Source"]
  )

  git_version = try(regex("\\?ref=(.+)", local.module_source)[0], null)

  tags = merge(
    var.required_tags,
    var.optional_tags,
    {hidden-gm_source = local.module_source},
    {hidden-gm_type = "Web App - Windows"},
    {GoldenModuleVersion = coalesce(local.git_version, "main")}
  )

}