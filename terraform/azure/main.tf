terraform {
  required_version = ">= 1.4.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0" # Updated to the latest major version
    }
  }
}

provider "azurerm" {
  features {}
  # Mandatory for version 4.x
  subscription_id = "e529965e-3ad3-427a-a1b4-c1b940fb2c62" 
}

# ---------------------------
# Resource Group
# ---------------------------
resource "azurerm_resource_group" "rg" {
  name     = "devops-rg"
  location = "eastus2"
}

# ---------------------------
# Virtual Network
# ---------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "devops-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# ---------------------------
# Subnet (AKS)
# ---------------------------
resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
} # Added missing closing brace here

# ---------------------------
# AKS Cluster (Free Tier Safe)
# ---------------------------
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "devops-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "devopsaks"

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = "Standard_D2s_v3"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "kubenet"
    service_cidr   = "10.2.0.0/24"
    dns_service_ip = "10.2.0.10"
  }

  tags = {
    environment = "dev"
    project     = "devops-multicloud"
  }

  # THIS IS THE FIX: It forces a pause until the network is ready
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_subnet.aks_subnet
  ]
}
