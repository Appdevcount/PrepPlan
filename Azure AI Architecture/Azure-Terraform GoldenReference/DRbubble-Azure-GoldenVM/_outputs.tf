output "vm_ids" {
  value = var.os_type == "Linux" ? azurerm_linux_virtual_machine.linux-vm.*.id : azurerm_windows_virtual_machine.windows-vm.*.id
}
output "vm_identities" {
  value = var.os_type == "Linux" ? azurerm_linux_virtual_machine.linux-vm.*.identity : azurerm_windows_virtual_machine.windows-vm.*.identity
}
output "vm_private_ips" {
  value = var.os_type == "Linux" ? azurerm_linux_virtual_machine.linux-vm.*.private_ip_address : azurerm_windows_virtual_machine.windows-vm.*.private_ip_address
}
output "network_interfaces" {
  value = azurerm_network_interface.vmnic.*
}
