terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "storageRG"
    storage_account_name = "taskboardstoragej"
    container_name       = "taskboardstoragecontainer"
    key                  = "terraform.tfstate"

  }
}



provider "azurerm" {
  subscription_id = "3556e95d-01ce-4530-a696-7b54261a79c2"
  features {}
}

resource "azurerm_resource_group" "arg" {
  name     = "${var.resource_group_name}-jeko"
  location = var.location
}

resource "azurerm_service_plan" "app-service-plan" {
  name                = "${var.app_service_plan_name}-jeko"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_resource_group.arg.location
  sku_name            = "F1"
  os_type             = "Linux"
}

resource "azurerm_linux_web_app" "web-app" {
  name                = "${var.app_service_name}-jeko"
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
  name                         = "${var.sql_server_name}-jeko"
  resource_group_name          = azurerm_resource_group.arg.name
  location                     = azurerm_resource_group.arg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_name
  administrator_login_password = var.sql_admin_pass
}


resource "azurerm_mssql_database" "mssqldb" {
  name                 = "${var.sql_db_name}-jeko"
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
  name             = "${var.firewall-rule-name}-jeko"
  server_id        = azurerm_mssql_server.mssqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_app_service_source_control" "source-control" {
  app_id                 = azurerm_linux_web_app.web-app.id
  repo_url               = var.github-repo-url
  branch                 = var.github-repo-branch
  use_manual_integration = true
}

resource "azurerm_resource_group" "storagerg" {
  name = "storageRG"
  location = var.location
}

resource "azurerm_storage_account" "storage_account" {
  name = "taskboardstoragej"
  resource_group_name = azurerm_resource_group.storagerg.name
  location = azurerm_resource_group.storagerg.location
  account_kind = "StorageV2"
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "storage_container" {
  name = "taskboardstoragecontainer"
  storage_account_id = azurerm_storage_account.storage_account.id
  container_access_type = "private"
}