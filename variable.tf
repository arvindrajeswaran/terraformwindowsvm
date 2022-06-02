variable "resource_group_name" {
  type        = string
  description = "Specifies the name of the resource group in which to create the Azure Network Base Infrastructure Resources."
}
variable "location" {
  type        = string
  description = "Specifies the name of the resource group in which to create the Azure Network Base Infrastructure Resources."
}

variable "resource_group_name2" {
  type        = string
}
variable "location2" {
  type        = string
  }

variable "virtual_networks" {
  description = "The virtal networks with their properties."
  type = map(object({
    name          = string
    address_space = list(string)
    dns_servers   = list(string)
    ddos_protection_plan = object({
      id     = string
      enable = bool
    })
  }))
  default = {}
}

# - Subnet object
# -
variable "subnets" {
  description = "The virtal networks subnets with their properties."
  type = map(object({
    name              = string
    vnet_key          = string
    vnet_name         = string
    address_prefixes  = list(string)
  }))
  default = {}
}

variable "windows_vm_nics" {
  type = map(object({
    name                           = string
    subnet_id                      = string
    internal_dns_name_label        = string
    enable_ip_forwarding           = bool
    enable_accelerated_networking  = bool
    dns_servers                    = list(string)
    ip_configuration_name = string
    subnet_key = string
    nic_ip_configurations = list(object({
      name      = string
      static_ip = string
    }))
  }))
  description = "Map containing Windows VM NIC objects"
  default     = {}
}