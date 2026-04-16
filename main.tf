terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}
provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-user15" #change here
    storage_account_name = "gastorageuser15" #change here
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}