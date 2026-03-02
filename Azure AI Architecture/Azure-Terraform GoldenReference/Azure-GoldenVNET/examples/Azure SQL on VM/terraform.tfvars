# Deployment Resource Group
AZ_SQL_RSG                              = "sb1_eu2_sql_mi_test"

# Key Vault
AZ_KEYVAULT_NAME                        = "sb1eu2sqltestkeyvault"

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
AZ_SQL_VNET                             = "sb1_eu2_sql_mi_vnet_test"
AZ_SQL_SUBNET                           = "sb1_eu2_sql_mi_subnet_test"

# Virtual Machine
AZ_SQL_VMNAME                           = "sb1eu2windowsvm"
AZ_SQL_VMSIZE                           = "Standard_F2"
AZ_SQL_VMSTORAGETYPE                    = "Standard_LRS"

# Backup Storage Account
AZ_SQL_SA_BACKUP_NAME                   = "sb1eu2sqlbackups"
AZ_SQL_SA_TIER                          = "Standard"
AZ_SQL_SA_REPLICATION                   = "LRS"
AZ_SQL_SA_PUBLICACCESS                  = false
AZ_SQL_SA_CROSSTENANTREPL               = false
AZ_SQL_SP                               = "c126a3ce-4837-4f0a-b9dd-967e21295c62"  # Enterprise Application: SP_sb1_eu2_sql_mi_test
AZ_SQL_KV_KEYTYPE                     = "RSA"
AZ_SQL_KV_KEYSIZE                     = 2048

# SQL on VM
AZ_SQL_LICENSE                          = "PAYG"
AZ_SQL_PORT                             = 1433
AZ_SQL_CONNECTIVITYTYPE                 = "PRIVATE"
AZ_SQL_BACKUPENCRYPTENABLED             = true
AZ_SQL_BACKUPSYSTEMDATABASES            = false
AZ_SQL_BACKUPRETENTION                  = 30
AZ_SQL_PATCHDAY                         = "Sunday"
AZ_SQL_MAINTWINDOWDURATION              = 60
AZ_SQL_MAINTWINDOWSTARTHOUR             = 2
