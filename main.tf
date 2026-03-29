terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "=3.8.1"
    }
  }
}


provider "azurerm" {
  subscription_id = "3556e95d-01ce-4530-a696-7b54261a79c2"
  features {}
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "arg" {
  name     = "taskboardrg-${random_integer.ri.result}"
  location = "Poland Central"
}

resource "azurerm_service_plan" "app-service-plan" {
  name                = "taskboard-service-plan-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_resource_group.arg.location
  sku_name            = "F1"
  os_type             = "Linux"
}

resource "azurerm_linux_web_app" "web-app" {
  name                = "taskboard-web-app-${random_integer.ri.result}"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name
  service_plan_id     = azurerm_service_plan.app-service-plan.id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }

    always_on = false
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.mssqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.mssqldb.name};User ID=${azurerm_mssql_server.mssqlserver.administrator_login};Password=${azurerm_mssql_server.mssqlserver.administrator_login_password};Trusted_Connection=False;MultipleActiveResultSets=True;"
  }
}


// PART 1 : 
resource "azurerm_mssql_server" "mssqlserver" {
  name                         = "mssql-server-${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.arg.name
  location                     = azurerm_resource_group.arg.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = "thisIsKat11"
}


resource "azurerm_mssql_database" "mssqldb" {
  name                 = "mssql-db-${random_integer.ri.result}"
  server_id            = azurerm_mssql_server.mssqlserver.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  license_type         = "LicenseIncluded"
  max_size_gb          = 2
  sku_name             = "Basic"
  zone_redundant       = false
  storage_account_type = "Local"

  lifecycle {
    prevent_destroy = true
  }
}


resource "azurerm_mssql_firewall_rule" "firewall" {
  name             = "mssql-firewall-rule-${random_integer.ri.result}"
  server_id        = azurerm_mssql_server.mssqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_app_service_source_control" "source-control" {
  app_id                 = azurerm_linux_web_app.web-app.id
  repo_url               = "https://github.com/JekoGyulev/AzureTaskBoard-Terraform"
  branch                 = "master"
  use_manual_integration = true
}