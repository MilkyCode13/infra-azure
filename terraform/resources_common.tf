resource "azurerm_resource_group" "rg" {
  name     = "multi-region-app"
  location = "eastus"
}

resource "azurerm_traffic_manager_profile" "traffic_manager_profile" {
  name                = "milkycodetestapp"
  resource_group_name = azurerm_resource_group.rg.name

  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "milkycodetestapp"
    ttl           = 60
  }

  monitor_config {
    protocol                     = "http"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 10
    timeout_in_seconds           = 5
    tolerated_number_of_failures = 0
  }
}

data "azurerm_dns_zone" "az_dns_zone" {
  name = "az.milkycode.tk"
}

resource "azurerm_dns_cname_record" "fancy_dns" {
  name                = "testapp"
  zone_name           = data.azurerm_dns_zone.az_dns_zone.name
  resource_group_name = data.azurerm_dns_zone.az_dns_zone.resource_group_name
  ttl                 = 120
  record              = "milkycodetestapp.trafficmanager.net"
}

resource "azurerm_private_dns_zone" "private_dns" {
  name                = "private.az.milkycode.tk"
  resource_group_name = azurerm_resource_group.rg.name
}
