subscription_id       = "75dbc8c6-6364-4eb1-91c1-3400a4010fb4"
app_service_plan_name = "tb-gm-asp-test"
web_app_name          = "gmtestlinuxwa135"
sku_name              = "P3v3"
resource_group_name   = "tb-gm-webapp-test"
environment           = "dev1"
location              = "eastus2"
required_tags         = {
                            AssetOwner           = "troy.braman@evicore.com"
                            CostCenter           = "61700200"
                            SecurityReviewID     = "notassigned"
                            ServiceNowAS         = "notassigned"
                            ServiceNowBA         = "notassigned"
                        }
virtualnetworksubnetid = "/subscriptions/75dbc8c6-6364-4eb1-91c1-3400a4010fb4/resourceGroups/dv1_rsg_eu2_infra_vnet/providers/Microsoft.Network/virtualNetworks/infra-vnet/subnets/infra-vnet-intg-subnet"
pe_subnet_id  = "/subscriptions/75dbc8c6-6364-4eb1-91c1-3400a4010fb4/resourceGroups/dv1_rsg_eu2_infra_vnet/providers/Microsoft.Network/virtualNetworks/infra-vnet/subnets/infra-private_endpoints-subnet"
ado_subnet    = "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_vnet_products/providers/Microsoft.Network/virtualNetworks/eu2_pd1_vnet_products/subnets/eu2_pd1_snet_products_devops_10.194.62.0_23"
web_diag = [{
    name                       = "diagnostic"
    log_analytics_workspace_id = "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_security_siem/providers/Microsoft.OperationalInsights/workspaces/pd1-cloudsiem"
  }]
  
alarm_funnel_environment = "Dev"
alarm_funnel_app_name    = "my-alarm-funnel-app-name"
