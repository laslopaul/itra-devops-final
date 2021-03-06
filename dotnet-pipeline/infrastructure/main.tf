terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "laslopaulgmim8"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

}

provider "azurerm" {
  features {}
}

# Create resource group for .NET application
resource "azurerm_resource_group" "dotnetapp" {
  name     = var.dotnetapp_rg_name
  location = var.location
}

# Create App Service Plan
resource "azurerm_app_service_plan" "dotnetapp" {
  name                = var.service_plan_name
  location            = azurerm_resource_group.dotnetapp.location
  resource_group_name = azurerm_resource_group.dotnetapp.name

  sku {
    tier = "Free"
    size = "F1"
  }
}

# Create Azure App Service
resource "azurerm_app_service" "dotnetapp_service" {
  name                = var.appservice_name
  location            = azurerm_resource_group.dotnetapp.location
  resource_group_name = azurerm_resource_group.dotnetapp.name
  app_service_plan_id = azurerm_app_service_plan.dotnetapp.id
}

# Create Azure SQL Server and database
resource "azurerm_sql_server" "sqlserver" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.dotnetapp.name
  location                     = azurerm_resource_group.dotnetapp.location
  version                      = "12.0"
  administrator_login          = var.sql_login
  administrator_login_password = var.sql_password
}

resource "azurerm_sql_firewall_rule" "allow_azure" {
  name                = var.sql_fw_rule_name
  resource_group_name = azurerm_resource_group.dotnetapp.name
  server_name         = azurerm_sql_server.sqlserver.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_sql_database" "sqldb" {
  name                             = var.db_name
  resource_group_name              = azurerm_resource_group.dotnetapp.name
  location                         = azurerm_resource_group.dotnetapp.location
  server_name                      = azurerm_sql_server.sqlserver.name
  requested_service_objective_name = "S0"
}