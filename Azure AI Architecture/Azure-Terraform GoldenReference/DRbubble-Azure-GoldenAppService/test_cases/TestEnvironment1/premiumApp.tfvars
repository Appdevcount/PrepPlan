resource_group_name = "GoldenAppServiceTest-rg"
name                = "newtestwebapp0921"
sku                 = "P1V2"
#Change for test 2
kind = "Linux"

required_tags = {
  AssetOwner        = "michael.schroeder@cigna.com"
  CostCenter        = "0004076"
  ServiceNowBA      = "n/a"
  ServiceNowAS      = "n/a"
  SecurityReviewID  = "n/a"
}

app_settings = {
  Setting1 = "one"
  Setting2 = "two"
}

connection_strings = [{
  name  = "Database"
  type  = "SQLServer"
  value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
}]

site_config = {
  linux_fx_version = "NODE|14-lts"
  http2_enabled    = "true"
}

ip_restriction = [{
  type     = "ip_address"
  name     = "test"
  priority = 5
  action   = "Allow"
  address  = "10.10.10.10/32"
}]