
resource "azurerm_resource_group" "metro_ride" {
  name     = "metro-ride-rg"
  location = "Canada Central"
}


# Azure Databricks Setup

resource "time_sleep" "wait_for_databricks_workspace" {
  depends_on = [
    azurerm_databricks_workspace.databricks
  ]

  create_duration = "30s"
}

data "databricks_current_user" "current_user" {
  depends_on = [
    time_sleep.wait_for_databricks_workspace
  ]
}

resource "azurerm_databricks_workspace" "databricks" {
  name                = "metro-ride-bricks"
  resource_group_name = azurerm_resource_group.metro_ride.name
  location            = azurerm_resource_group.metro_ride.location
  sku                 = "premium"

  tags = {
    environment = "development"
    managed_by  = "terraform"
  }
}

data "databricks_node_type" "smallest" {
  local_disk = true
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}


# "15.4.x-scala2.12"
# "18.x-scala2.13"
# "Standard_D4s_v3"
resource "databricks_cluster" "metro_ride_cluster" {
  cluster_name            = "metro_ride_cluster"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 20

  data_security_mode = "DATA_SECURITY_MODE_DEDICATED"
  is_single_node = true
  kind = "CLASSIC_PREVIEW"
  single_user_name   = data.databricks_current_user.current_user.user_name

  custom_tags = {
    environment = "development"
    managed_by  = "terraform"
  }

  depends_on = [
    time_sleep.wait_for_databricks_workspace
  ]
}


# Create Azure Storage Account
data "azurerm_storage_account" "metro_ride_storage_data" {
  name                = azurerm_storage_account.metro_ride.name
  resource_group_name = azurerm_resource_group.metro_ride.name
  depends_on          = [azurerm_storage_account.metro_ride]
}

resource "azurerm_storage_account" "metro_ride" {
  name                     = "metroridestorage"
  resource_group_name      = azurerm_resource_group.metro_ride.name
  location                 = "Canada Central"
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "bronze"{
  name = "bronze"
  storage_account_name = azurerm_storage_account.metro_ride.name
  container_access_type = "private"
  depends_on = [ azurerm_storage_account.metro_ride ]
}
