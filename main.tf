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
