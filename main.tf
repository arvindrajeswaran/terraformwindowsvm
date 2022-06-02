# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

#second resource group
resource "azurerm_resource_group" "rg2" {
  name     = var.resource_group_name2
  location = var.location2
}

resource "azurerm_virtual_network" "example" {
  for_each            = var.virtual_networks
  name                = each.value["name"]
  location            = azurerm_resource_group.this.location #local.location
  resource_group_name = var.resource_group_name
  address_space       = each.value["address_space"]
  dns_servers         = lookup(each.value, "dns_servers", null)

  dynamic "ddos_protection_plan" {
    for_each = lookup(each.value, "ddos_protection_plan", null) != null ? tolist([lookup(each.value, "ddos_protection_plan")]) : []
    content {
      id     = lookup(ddos_protection_plan.value, "id", null)
      enable = coalesce(lookup(ddos_protection_plan.value, "enable"), false)
    }
  }
}

resource "azurerm_subnet" "this" {
  for_each                                       = var.subnets
  name                                           = each.value["name"]
  resource_group_name                            = var.resource_group_name
  address_prefixes                               = each.value["address_prefixes"]
  #virtual_network_name                           = each.value.vnet_key != null ? lookup(var.virtual_networks, each.value["vnet_key"])["name"] : data.azurerm_virtual_network.this[each.key].name
  virtual_network_name                           = lookup(var.virtual_networks, each.value["vnet_key"])["name"]
  depends_on = [azurerm_virtual_network.example]
}


# - Windows Network Interfaces
# -
resource "azurerm_network_interface" "windows_nics" {
  for_each                      = var.windows_vm_nics
  name                          = each.value.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  internal_dns_name_label       = lookup(each.value, "internal_dns_name_label", null)
  enable_ip_forwarding          = lookup(each.value, "enable_ip_forwarding", null)
  enable_accelerated_networking = lookup(each.value, "enable_accelerated_networking", null)
  dns_servers                   = lookup(each.value, "dns_servers", null)

  dynamic "ip_configuration" {
    for_each = coalesce(each.value.nic_ip_configurations, [])
    content {
      name                          = each.value.ip_configuration_name
      subnet_id                     = each.value.subnet_id
      private_ip_address_allocation = lookup(ip_configuration.value, "static_ip", null) == null ? "Dynamic" : "Static"
      private_ip_address            = lookup(ip_configuration.value, "static_ip", null)
    }
  }
  depends_on = [azurerm_subnet.this]
}