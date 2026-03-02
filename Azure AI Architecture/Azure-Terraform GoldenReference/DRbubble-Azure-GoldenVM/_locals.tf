# This file should only contain local variable declarations that are used globally within a module. If
# a local is defined to support creation of a specific resource, that local should be included in the same
# .tf file as the resource being created to improve code readability.

locals {
  tags = merge(
    var.required_tags,
    var.optional_tags
  )
  data_tags = merge(
    var.required_tags,
    var.optional_tags,
    var.required_data_tags,
    var.optional_data_tags
  )
  linux_gallery               = "LinuxComputeGallery"
  windows_gallery             = "WindowsComputeGallery"
  gallery_resource_group_name = "computegallery-rg"


  #plan publisher info is required for deployment of Linux images, and varies based on version in gallery
  image_offer_map = {
    WindowsServer2019 = "n/a"
    Ubuntu2004CIS     = "cis-ubuntu"
    Ubuntu2004CISstig = "cis-ubuntu"
#    Ubuntu2204CIS     = "cis-ubuntu-linux-2204-stig"
  }
  image_sku_map = {
    WindowsServer2019 = "n/a"
    Ubuntu2004CIS     = "cis-ubuntulinux2004-stig-gen1"
    Ubuntu2004CISstig = "cis-ubuntulinux2004-stig-gen1"
#    Ubuntu2204CIS     = "cis-ubuntu-linux-2204-stig"
  }
  plan_publisher = "center-for-internet-security-inc"
  plan_offer     = local.image_offer_map[var.image_name]
  plan_sku       = local.image_sku_map[var.image_name]
}
