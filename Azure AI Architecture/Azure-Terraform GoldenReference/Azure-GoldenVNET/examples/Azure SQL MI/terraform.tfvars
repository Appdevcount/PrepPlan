# Deployment Resource Group
AZ_SQL_RSG                              = "sb1_eu2_sql_mi_test"

# Key Vault
AZ_KEYVAULT_NAME                        = "sb1eu2sqltestkeyvault"
AZ_SQL_SA_KV_ACCOUNT_NAME               = "sqlsasampleusername"
AZ_SQL_SA_KV_ACCOUNT_PASSWORD           = "sqlsasamplepassword"

# SIEM Logging Information
AZ_PRODUCTION_SUBSCRIPTIONID            = "a0c6645e-c3da-4a78-9ef6-04ab6aad45ff"
AZ_TENANTID                             = "595de295-db43-4c19-8b50-183dfd4a3d06"
AZ_SIEM_SECURITY_RSG                    = "pd1_rsg_eu2_security_siem"
AZ_SIEM_WORKSPACE_NAME                  = "Pd1-CloudSIEM"

# Tags
AZ_SQL_TAGS = {
    CostCenter = "61700200"
    AssetOwner = "eviCore Cloud COE"
    BusinessOwner = "Amie Haltom (ahaltom@evicore.com)"
    DataClassification = "Internal"
    AppName = "Cloud COE"
    ITSponsor = "Amie Haltom (ahaltom@evicore.com)"
    Tier = "2"
  }

# Networking
AZ_SQL_NSG                           = "sb1-eu2-sqlmi-security-group"
AZ_SQL_VNET                          = "sb1_eu2_sql_mi_vnet_test"
AZ_SQL_SUBNET                        = "sb1_eu2_sql_mi_subnet_test"

# SQL Managed Instance
AZ_SQL_NAME                          = "sb1-eu2-sqlmisample"
AZ_SQL_LICENSE_TYPE                  = "BasePrice"
AZ_SQL_SKU_NAME                      = "GP_Gen5"
AZ_SQL_STORAGE_SIZE                  = 32
AZ_SQL_VCORES                        = 4
AZ_SQL_TLS_VERSION                   = "1.2"

# Storage Account for Vuln Assessment
AZ_SQL_SA_NAME                        = "sqldbvastorage"
AZ_SQL_SA_TIER                        = "Standard"
AZ_SQL_SA_REPLICATION                 = "LRS"
AZ_SQL_SA_PUBLICACCESS                = false
AZ_SQL_SA_CROSSTENANTREPL             = false
AZ_SQL_KV_KEYTYPE                     = "RSA"
AZ_SQL_KV_KEYSIZE                     = 2048

# Vulnerability Assessment
AZ_SQL_VA_TIER                        = "Standard"
AZ_SQL_VA_EMAILS                      = [ "responsible.person.or.group@evicore.com" ]
