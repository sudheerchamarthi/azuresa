provider "azurerm" {
  subscription_id = var.subscriptionid
  client_id       = var.clientId
  client_secret   = var.clientsecret
  tenant_id       = var.tenantID
  
  features {}
}


variable "tenantID" {
  default = {}
}

variable "subscriptionid" {
  default = {}
}

variable "clientId" {
  default = {}
}

variable "clientsecret" {
  default = {}
}

variable "location" {
  default = {}
}

variable "rgname" {
  default = {}
}

locals {
  virtual_network_name = "default"
  allowed_subnets = [
    "default1",
    "default2"
  ]
  storageaccount_name             = "g3privatestorage"
  storageaccount_tier             = "Standard"
  storageaccount_replication_type = "LRS"

}


data "azurerm_subnet" "allowed_subnets" {
  for_each             = toset(local.allowed_subnets)
  name                 = each.value
  virtual_network_name = local.virtual_network_name
  resource_group_name  = var.rgname
}

resource "azurerm_storage_account" "storage_account" {
  name                     = local.storageaccount_name
  resource_group_name      = var.rgname
  location                 = var.location
  account_tier             = local.storageaccount_tier
  account_replication_type = local.storageaccount_replication_type

  network_rules {
    default_action = "Deny"

    virtual_network_subnet_ids = [
      for s in data.azurerm_subnet.allowed_subnets : s.id
    ]
  }
}

