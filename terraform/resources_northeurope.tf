resource "azurerm_virtual_network" "northeurope_vnet" {
  name                = "northeurope-vnet"
  address_space       = ["10.2.0.0/16"]
  location            = "northeurope"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "northeurope_subnet" {
  name                 = "northeurope-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.northeurope_vnet.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_public_ip" "northeurope_public_ip" {
  name                = "northeurope-public-ip"
  location            = "northeurope"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label   = "milkycode-northeurope"
}

resource "azurerm_network_interface" "northeurope_edge_interface" {
  name                = "northeurope-edge-interface"
  location            = "northeurope"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "northeurope-edge-interface-ip-config"
    subnet_id                     = azurerm_subnet.northeurope_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.2.1.4"
    public_ip_address_id          = azurerm_public_ip.northeurope_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "northeurope_edge" {
  name                  = "northeurope-edge"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = "northeurope"
  size                  = "Standard_B1s"
  admin_username        = "azadmin"
  network_interface_ids = [azurerm_network_interface.northeurope_edge_interface.id]
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

resource "azurerm_network_interface" "northeurope_k8s_master_interface" {
  name                = "northeurope-k8s-master-interface"
  location            = "northeurope"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "northeurope-k8s-master-interface-ip-config"
    subnet_id                     = azurerm_subnet.northeurope_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.2.1.5"
  }
}

resource "azurerm_linux_virtual_machine" "northeurope_k8s_master" {
  name                  = "northeurope-k8s-master"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = "northeurope"
  size                  = "Standard_B2s"
  admin_username        = "azadmin"
  network_interface_ids = [azurerm_network_interface.northeurope_k8s_master_interface.id]
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

resource "azurerm_network_interface" "northeurope_k8s_node1_interface" {
  name                = "northeurope-k8s-node1-interface"
  location            = "northeurope"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "northeurope-k8s-node1-interface-ip-config"
    subnet_id                     = azurerm_subnet.northeurope_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.2.1.6"
  }
}

resource "azurerm_linux_virtual_machine" "northeurope_k8s_node1" {
  name                  = "northeurope-k8s-node1"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = "northeurope"
  size                  = "Standard_B2s"
  admin_username        = "azadmin"
  network_interface_ids = [azurerm_network_interface.northeurope_k8s_node1_interface.id]
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

# resource "azurerm_network_interface" "northeurope_k8s_node2_interface" {
#   name                = "northeurope-k8s-node2-interface"
#   location            = "northeurope"
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "northeurope-k8s-node2-interface-ip-config"
#     subnet_id                     = azurerm_subnet.northeurope_subnet.id
#     private_ip_address_allocation = "Static"
#     private_ip_address            = "10.2.1.7"
#   }
# }

# resource "azurerm_linux_virtual_machine" "northeurope_k8s_node2" {
#   name                  = "northeurope-k8s-node2"
#   resource_group_name   = azurerm_resource_group.rg.name
#   location              = "northeurope"
#   size                  = "Standard_B1s"
#   admin_username        = "azadmin"
#   network_interface_ids = [azurerm_network_interface.northeurope_k8s_node2_interface.id]
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

resource "azurerm_traffic_manager_endpoint" "northeurope_traffic_manager_profile" {
  name                = "northeurope-traffic-manager-profile"
  resource_group_name = azurerm_resource_group.rg.name
  profile_name        = azurerm_traffic_manager_profile.traffic_manager_profile.name
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.northeurope_public_ip.id
}

resource "azurerm_virtual_network_peering" "northeurope_to_eastus" {
  name                      = "northeurope-to-eastus"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.northeurope_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.eastus_vnet.id
}

resource "azurerm_dns_a_record" "northeurope_dns_record" {
  name                = "northeurope"
  zone_name           = data.azurerm_dns_zone.az_dns_zone.name
  resource_group_name = data.azurerm_dns_zone.az_dns_zone.resource_group_name
  ttl                 = 120
  target_resource_id  = azurerm_public_ip.northeurope_public_ip.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "northeurope_private_dns" {
  name                  = "northeurope-private-dns"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id    = azurerm_virtual_network.northeurope_vnet.id
  registration_enabled  = true
}
