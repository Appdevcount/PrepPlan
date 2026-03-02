app_service_plan_name = "tb-gm-asp-test"
resource_group_name   = "tb-gm-webapp-func-test"
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

functions_to_create = {
  "tbtestfunc0001" = {
                      app_settings = {
                                      TESTSETTING1="Value1"
                                      TESTSETTING2 = "Value2" }
                     },
  "tbtestfunc0002" = {
                      app_settings = {
                                      TESTSETTING3="Value3"
                                      TESTSETTING4 = "Value4" }
                     }                 

}

alarm_funnel_ag_subscription_id = "4291f6cb-6acb-4857-8d9a-3510df28ce1d"