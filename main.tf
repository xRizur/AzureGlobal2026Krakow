terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.68.0"
    }
  }
}
provider "azurerm" {
  features {}
}

locals {
    resource_group_name = "rg-user15"
    location            = "swedencentral"
}

data "azurerm_user_assigned_identity" "example" {
  name                = "ga-mi-user15"
  resource_group_name = local.resource_group_name
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-user15" #change here
    storage_account_name = "gastorageuser15" #change here
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

module "keyvault" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git?ref=keyvault/v1.0.0"
  # also any inputs for the module (see below)

  keyvault_name = "kv-user15"
  resource_group = {
    location = local.location
    name     = local.resource_group_name
  }
  network_acls = {
    default_action = "Allow"
    bypass         = "AzureServices"
    ip_rules       = ["0.0.0.0/0"]
  }
}

module "service_plan" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git?ref=service_plan/v2.0.0"
  # also any inputs for the module (see below)
  app_service_plan_name = "asp-user15"
  sku_name = "P1v2"
  tags = {
  }
  resource_group = {
    location = local.location
    name     = local.resource_group_name
  }
}

module "app_service" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git?ref=app_service/v1.0.0"
  # also any inputs for the module (see below)
  app_service_name = "as-user15"
  app_service_plan_id = module.service_plan.app_service_plan.id
  identity_client_id = data.azurerm_user_assigned_identity.example.client_id
  identity_id = data.azurerm_user_assigned_identity.example.id
  resource_group = {
    location = local.location
    name     = local.resource_group_name
  }
  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = module.application_insights.instrumentation_key
  }
}

module "mssql_server" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git?ref=mssql_server/v1.0.0"
  # also any inputs for the module (see below)
  resource_group = {
    location = local.location
    name     = local.resource_group_name
  }
  sql_server_admin = "user15"
  sql_server_name = "mssql-user15"
  sql_server_version = "12.0"

}

module "container_registry" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git?ref=container_registry/v1.0.0"
  # also any inputs for the module (see below)
    resource_group = {
        location = local.location
        name     = local.resource_group_name
    }
    container_registry_name = "acruser15"
    read_access = ["${data.azurerm_user_assigned_identity.example.id}"]
    write_access = ["${data.azurerm_user_assigned_identity.example.id}"]
}

module "application_insights" {
  source = "git::https://github.com/pchylak/global_azure_2026_ccoe.git?ref=application_insights/v1.0.0"
  # also any inputs for the module (see below)
  application_insights_name = "appi-user15"
  log_analytics_name = "la-user15"
  resource_group = {
        location = local.location
        name     = local.resource_group_name
    }
}