resource "azurerm_mssql_server" "devops_sql_server" {
  name                         = "ruman-devops-sql-server"
  resource_group_name          = azurerm_resource_group.rg.name  # Changed .main to .rg
  location                     = azurerm_resource_group.rg.location # Changed .main to .rg
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "Password123!" 

  tags = {
    environment = "dev"
  }
}

resource "azurerm_mssql_database" "devops_db" {
  name           = "devopsdb"
  server_id      = azurerm_mssql_server.devops_sql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "BasePrice"
  max_size_gb    = 2
  sku_name       = "S0" 

  tags = {
    environment = "dev"
  }
}
