resource_group_name = "test-Azure-GoldenVM-rg"
name                = "windowsTest"
required_tags = {
  AssetOwner       = "michael.schroeder@cigna.com"
  CostCenter       = "0004076"
  SecurityReviewID = "n/a"
  ServiceNowBA     = "n/a"
  ServiceNowAS     = "n/a"
}
required_data_tags = {
  DataSubjectArea        = "OS only - testing deployment"
  ComplianceDataCategory = "none"
  DataClassification     = "Public"
  BusinessEntity         = "Cigna"
  LineOfBusiness         = "Cloud COE"
}
nics = [{
  subnet_name          = "default"
  virtual_network_name = "sandbox-vnet"
}]
os_type          = "Windows"
image_name       = "WindowsServer2019"
image_version_id = "latest"
size             = "Standard_D2ds_v4"
admin_username   = "azadmin"
admin_password   = "CrazyWilly8ball!candy"
data_disks       = []
