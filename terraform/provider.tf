terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.69.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.14.0"
    }

    databricks = {
      source  = "databricks/databricks"
      version = "1.117.0"
    }

  }
}

provider "azurerm" {
  features {
  }
  subscription_id = file("credentials.txt")
}

provider "databricks" {
  host                        = azurerm_databricks_workspace.databricks.workspace_url
  azure_workspace_resource_id = azurerm_databricks_workspace.databricks.id
}

