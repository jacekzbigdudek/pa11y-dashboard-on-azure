output "instance_id" {
    description = " id of created instances. "
    value       = azurerm_linux_virtual_machine.main.id
}

output "private_ip" {
    description = "Private IPs of created instances. "
    value       = azurerm_linux_virtual_machine.main.private_ip_address
}

output "public_ip" {
    description = "Public IPs of created instances. "
    value       = azurerm_public_ip.pip.ip_address
}
