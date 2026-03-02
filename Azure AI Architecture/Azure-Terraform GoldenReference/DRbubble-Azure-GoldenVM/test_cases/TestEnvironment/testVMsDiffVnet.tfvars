resource_group_name     = "test-Azure-GoldenVM-rg"
nic_resource_group_name = "test-Azure-GoldenVM2-rg"
name                    = "GVMTest2"
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
  subnet_name          = "vmgmtest-snet"
  virtual_network_name = "vmgmtest-vnet"
}]

VMs = {
  Linux2004-vm = {
    os_type          = "Linux"
    image_name       = "Ubuntu2004CIS"
    image_version_id = "latest"
    size             = "Standard_D4as_v4"
    admin_username   = "azadmin"
    admin_password   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDC/lMKJUuFjHvww8HODFsjyWn1qBPLxq4DbyM6TLE9InG4vAKHFFf6K0M9gFMhiPgbNOFI/4NPQkkMP/BCSkWpnSMs+OrqD0UqIGY+IpB+6+5+A0rRUqQzphGPmxcRtvcQ2KsYpwzcCQ34MQWkHBMxRuw2MMotdF5e9pY60VU0lIwEvLjtM9bUlO+YqQ54HcM75dDDZWJNX/z3cN73hRT+xAA4hobzEOXnhJBb5t4G/Nm9AgXF7kMR1jfe6aRmVkFEQK3PHrnX0CjMvTpy01bFX35R3iKF1UToOtzalbcXl1cpK3lytpDRX72Db2zSpiWGnHlC0FcyVDzf7OB9Yg08sKGPKVQH8rnyrtSfbUNQxZlpgP0DGLuqzZJMIWu5OAwuxJpXRghArNRJWR/YO6/dCqlyeLvNRM1boeSS1CSZK2HGKkNHlsiCaB5SNxsTqp3UoIVQhB8WOe5OdOmBEedH/mD3EtIMHQ/A+AJBxplCjlZVzff9wMoy1YrJ5MCnRL0= generated-by-azure"
    data_disks = [{
      name                 = "01"
      disk_size_gb         = "5"
      storage_account_type = "Standard_LRS"
      lun                  = "10"
      caching              = "ReadWrite"
    }]
    custom_data = null
  },
  Win2019-vm = {
    os_type          = "Windows"
    image_name       = "WindowsServer2019"
    image_version_id = "latest"
    size             = "Standard_D2ds_v4"
    admin_username   = "azadmin"
    admin_password   = "CrazyWilly8ball!candy"
    data_disks       = []
    custom_data      = null
  }
}
