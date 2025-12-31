resource "azurerm_storage_account" "devops_storage" {
  name                     = "rumandevopsstorage123" # Must be lowercase/unique
  resource_group_name      = azurerm_resource_group.rg.name  # Changed .main to .rg
  location                 = azurerm_resource_group.rg.location # Changed .main to .rg
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_storage_container" "devops_container" {
  name                  = "projectfiles"
  storage_account_name  = azurerm_storage_account.devops_storage.name
  container_access_type = "private"
}
