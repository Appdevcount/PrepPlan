resource_group_name         = "keyvault-test-rg"
name                        = "cloudcoedev-key-vault"
enabled_for_disk_encryption = true

required_tags = {
  AssetOwner            = "zebadiah.ramos@cigna.com"
  CostCenter            = "0004706"
  SecurityReviewID      = "n/a"
  ServiceNowAS          = "n/a"
  ServiceNowBA          = "n/a"
}

optional_tags = {
  BackupOwner  = "seth.gaston@cigna.com"
}

allowed_ip_rules = ["170.48.0.0/16", "208.242.14.0/24", "167.18.104.0/24", "167.211.104.0/24"]

private_endpoint_subnet_ids = []
vnet_names                  = []

disk_encryption_sets = {
  "des_workloada" = {
    encryption_key = "azurediskkeyworkloada"
  }
}
