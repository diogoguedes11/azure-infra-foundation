terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "=3.1.0"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
}
