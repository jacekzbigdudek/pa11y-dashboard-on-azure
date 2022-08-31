output "URL" {
    description = "URL for the pa11y-dashboard web service."
    value       = azurerm_public_ip.pip.fqdn
}

output "ip" {
    description = "Public IP of created VM instance."
    value       = azurerm_public_ip.pip.ip_address
}

output "login" {
    description = "Login name of administrator account."
    value       = azurerm_linux_virtual_machine.main.admin_username
}

# output "instance_id" {
#     description = "id of created VM instance."
#     value       = azurerm_linux_virtual_machine.main.id
# }

# output "private_ip" {
#     description = "Private IP of created instance."
#     value       = azurerm_linux_virtual_machine.main.private_ip_address
# }

