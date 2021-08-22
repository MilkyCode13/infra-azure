output "eastus_public_ip" {
  value = azurerm_public_ip.eastus_public_ip.ip_address
}

output "northeurope_public_ip" {
  value = azurerm_public_ip.northeurope_public_ip.ip_address
}
