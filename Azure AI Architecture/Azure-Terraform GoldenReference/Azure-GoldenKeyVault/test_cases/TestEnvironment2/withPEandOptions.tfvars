resource_group_name             = "keyvault-test-rg"
name                            = "goldenModuleTest-PE"
enable_rbac_authorization       = false
enabled_for_disk_encryption     = false
enabled_for_template_deployment = false

required_tags = {
  AssetOwner       = "michael.schroeder@cigna.com"
  CostCenter       = "0004706"
  SecurityReviewID = "n/a"
  ServiceNowAS     = "n/a"
  ServiceNowBA     = "n/a"
}

optional_tags = {
  BackupOwner = "seth.gaston@cigna.com"
}

allowed_ip_rules = ["170.48.0.0/16", "165.225.0.0/16"]

initial_access_assignments = [
  {
    principal_id = "self"
    roles        = ["Key Vault Administrator", "Key Vault Crypto Officer"]
  }
]
