name                = "goldenModuleTest-RBAC-kv"
location            = "eastus"
resource_group_name = "keyvault-test-rg"

required_tags = {
  AssetOwner       = "michael.schroeder@cigna.com"
  CostCenter       = "0004706"
  SecurityReviewID = "n/a"
  ServiceNowAS     = "n/a"
  ServiceNowBA     = "n/a"
}

enable_rbac_authorization = true

initial_access_assignments = [
  {
    principal_id = "self"
    roles        = ["Key Vault Administrator", "Key Vault Crypto Officer"]
  },
  {
    principal_id = "3075a92d-890f-4431-912e-8c2014f1db7c"
    roles        = ["Key Vault Crypto Service Encryption User"]
  }
]
