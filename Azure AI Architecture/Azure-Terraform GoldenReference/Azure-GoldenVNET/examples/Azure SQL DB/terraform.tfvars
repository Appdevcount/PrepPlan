# Deployment Resource Group
AZ_SQL_RSG                              = "sb1_eu2_sql_mi_test"

# Key Vault
AZ_KEYVAULT_NAME                        = "sb1eu2sqltestkeyvault"
AZ_SQL_SA_KV_ACCOUNT_NAME             = "sqlsasampleusername"
AZ_SQL_SA_KV_ACCOUNT_PASSWORD         = "sqlsasamplepassword"

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

# Azure SQL DB
AZ_SQL_NAME                           = "sb1-eu2-sqldbsample"
AZ_SQL_VERSION                        = "12.0"
AZ_SQL_TLS_VERSION                    = "1.2"
AZ_SQL_CONNECTION_POLICY              = "Default"
AZ_SQL_PUBLIC_NETWORK_ACCESS          = false
AZ_SQL_AZURE_AD_AUTHENTICATION_ONLY   = true
AZ_SQL_SA_AAD_LOGIN                   = "sql_sa_aad_login"
AZ_SQL_AZUREAD_ADMIN_OBJECT_ID        = "e747ad10-da8f-4a3c-af16-1cc346ecbe4e"
AZ_SQL_COLLATION                      = "SQL_Latin1_General_CP1_CI_AS"
AZ_SQL_LICENSE                        = "LicenseIncluded"
AZ_SQL_MAXSIZE                        = 5
AZ_SQL_READSCALE                      = null
AZ_SQL_SKU                            = "S0"
AZ_SQL_ZONEREDUNDANT                  = null
AZ_SQL_WEEKLY_RETENTION               = "P1M"
AZ_SQL_MONTHLY_RETENTION              = null
AZ_SQL_YEARLY_RETENTION               = null
AZ_SQL_WEEKOFYEAR                     = 0       # Required, even if only weekly or monthly retention is selected

# Storage Account for Vuln Assessment
AZ_SQL_SA_NAME                        = "sqldbvastorage"
AZ_SQL_SA_TIER                        = "Standard"
AZ_SQL_SA_REPLICATION                 = "LRS"

# Vulnerability Assessment
AZ_SQL_VA_EMAILS                      = [ "responsible.person.or.group@evicore.com" ]

# Private Endpoint
AZ_SQL_PE_VNETNAME                    = "sb1_eu2_sql_mi_vnet_test"
AZ_SQL_PE_SUBNETNAME                  = "sb1_eu2_sql_mi_subnet_test_pe"
AZ_SQL_PE_ZONENAME                    = "evicoresandbox"
AZ_SQL_PE_PRIVATENAME                 = "sb1eu2sqldbsample.lan"
AZ_SQL_PE_PRIVATEENDPOINTNAME         = "sb1eu2sqldbpe"

# Customer-Managed Key Encryption
AZ_SQL_KV_KEYTYPE                   = "RSA"
AZ_SQL_KV_KEYSIZE                   = 2048