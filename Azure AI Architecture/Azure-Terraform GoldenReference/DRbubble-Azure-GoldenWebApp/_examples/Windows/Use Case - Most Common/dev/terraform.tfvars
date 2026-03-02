subscription_id       = "75dbc8c6-6364-4eb1-91c1-3400a4010fb4"
app_service_plan_name = "tb-gm-asp-test"
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

ip_restriction = [
    {
      name                      = "atl"
      action                    = "Allow"
      priority                  = 100
      ip_address                = "199.204.156.0/22"
    },
    {
      name                      = "dal"
      action                    = "Allow"
      priority                  = 101
      ip_address                = "198.27.9.0/24"
    },
    {
      name                      = "vnet_intg"
      action                    = "Allow"
      priority                  = 102
      virtual_network_subnet_id = "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_vnet_products/providers/Microsoft.Network/virtualNetworks/eu2_pd1_vnet_products/subnets/eu2_pd1_snet_products_devops_10.194.62.0_23"
    },
    {
      name                      = "Allowed Hosts"
      action                    = "Allow"
      priority                  = 103
      ip_address                = "198.27.9.0/24"
      headers                   = [{
                                    x_forwarded_host  = ["www.test.com"]
                                  }]
    }
]

scm_ip_restriction = [
    {
      name                      = "atl"
      action                    = "Allow"
      priority                  = 100
      ip_address                = "199.204.156.0/22"
    },
    {
      name                      = "dal"
      action                    = "Allow"
      priority                  = 101
      ip_address                = "198.27.9.0/24"
    },
    {
      name                      = "vnet_intg"
      action                    = "Allow"
      priority                  = 102
      virtual_network_subnet_id = "/subscriptions/a0c6645e-c3da-4a78-9ef6-04ab6aad45ff/resourceGroups/pd1_rsg_eu2_vnet_products/providers/Microsoft.Network/virtualNetworks/eu2_pd1_vnet_products/subnets/eu2_pd1_snet_products_devops_10.194.62.0_23"
    },
    {
      name                      = "Allowed Hosts"
      action                    = "Allow"
      priority                  = 103
      ip_address                = "198.27.9.0/24"
      headers                   = [{
                                    x_forwarded_host  = ["www.test.com"]
                                  }]
    },
    {
      name                      = "Allowed Hosts-2"
      action                    = "Allow"
      priority                  = 104
      ip_address                = "198.30.9.0/24"
      headers                   = [{
                                    x_forwarded_host  = ["www.test.com"]
                                  }]
    }
]

