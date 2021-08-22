resource "azurerm_virtual_network" "eastus_vnet" {
  name                = "eastus-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "eastus_subnet" {
  name                 = "eastus-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.eastus_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_public_ip" "eastus_public_ip" {
  name                = "eastus-public-ip"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label   = "milkycode-eastus"
}

resource "azurerm_network_interface" "eastus_edge_interface" {
  name                = "eastus-edge-interface"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "eastus-edge-interface-ip-config"
    subnet_id                     = azurerm_subnet.eastus_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.1.4"
    public_ip_address_id          = azurerm_public_ip.eastus_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "eastus_edge" {
  name                  = "eastus-edge"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = "eastus"
  size                  = "Standard_B1s"
  admin_username        = "azadmin"
  network_interface_ids = [azurerm_network_interface.eastus_edge_interface.id]
  admin_ssh_key {
    username   = "azadmin"
    public_key = file("../.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "eastus_k8s_master_interface" {
  name                = "eastus-k8s-master-interface"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "eastus-k8s-master-interface-ip-config"
    subnet_id                     = azurerm_subnet.eastus_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.1.5"
  }
}

resource "azurerm_linux_virtual_machine" "eastus_k8s_master" {
  name                  = "eastus-k8s-master"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = "eastus"
  size                  = "Standard_B2s"
  admin_username        = "azadmin"
  network_interface_ids = [azurerm_network_interface.eastus_k8s_master_interface.id]
  admin_ssh_key {
    username   = "azadmin"
    public_key = file("../.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "eastus_k8s_node1_interface" {
  name                = "eastus-k8s-node1-interface"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "eastus-k8s-node1-interface-ip-config"
    subnet_id                     = azurerm_subnet.eastus_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.1.6"
  }
}

resource "azurerm_linux_virtual_machine" "eastus_k8s_node1" {
  name                  = "eastus-k8s-node1"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = "eastus"
  size                  = "Standard_B2s"
  admin_username        = "azadmin"
  network_interface_ids = [azurerm_network_interface.eastus_k8s_node1_interface.id]
  admin_ssh_key {
    username   = "azadmin"
    public_key = file("../.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

# resource "azurerm_network_interface" "eastus_k8s_node2_interface" {
#   name                = "eastus-k8s-node2-interface"
#   location            = "eastus"
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "eastus-k8s-node2-interface-ip-config"
#     subnet_id                     = azurerm_subnet.eastus_subnet.id
#     private_ip_address_allocation = "Static"
#     private_ip_address            = "10.1.1.7"
#   }
# }

# resource "azurerm_linux_virtual_machine" "eastus_k8s_node2" {
#   name                  = "eastus-k8s-node2"
#   resource_group_name   = azurerm_resource_group.rg.name
#   location              = "eastus"
#   size                  = "Standard_B1s"
#   admin_username        = "azadmin"
#   network_interface_ids = [azurerm_network_interface.eastus_k8s_node2_interface.id]
#   admin_ssh_key {
#     username   = "azadmin"
#     public_key = file("../.ssh/id_rsa.pub")
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "canonical"
#     offer     = "0001-com-ubuntu-server-focal"
#     sku       = "20_04-lts"
#     version   = "latest"
#   }
# }

resource "azurerm_traffic_manager_endpoint" "eastus_traffic_manager_profile" {
  name                = "eastus-traffic-manager-profile"
  resource_group_name = azurerm_resource_group.rg.name
  profile_name        = azurerm_traffic_manager_profile.traffic_manager_profile.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.eastus_public_ip.id
}

resource "azurerm_virtual_network_peering" "eastus_to_northeurope" {
  name                      = "eastus-to-northeurope"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.eastus_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.northeurope_vnet.id
}

resource "azurerm_dns_a_record" "eastus_dns_record" {
  name                = "eastus"
  zone_name           = data.azurerm_dns_zone.az_dns_zone.name
  resource_group_name = data.azurerm_dns_zone.az_dns_zone.resource_group_name
  ttl                 = 120
  target_resource_id  = azurerm_public_ip.eastus_public_ip.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "eastus_private_dns" {
  name                  = "eastus-private-dns"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id    = azurerm_virtual_network.eastus_vnet.id
  registration_enabled  = true
}
