
output "test_resource_group" {
  value = azurerm_resource_group.az_rg.name
}


output "databricks_azure_workspace_resource_id" {
  //The ID of the Databricks Workspace in the Azure management plane.
  value = azurerm_databricks_workspace.databrick_workspace.id
}

output "workspace_url" {
  //The workspace URL which is of the format 'adb-{workspaceId}.{random}.azuredatabricks.net'
  //this is not named as DATABRICKS_HOST, because it affect authentication
  value = "https://${azurerm_databricks_workspace.databrick_workspace.workspace_url}/"
}

output "databricks_managed_resource_group" {
  value = azurerm_databricks_workspace.databrick_workspace.managed_resource_group_name
}

output "databricks_managed_resource_group_id" {
  value = azurerm_databricks_workspace.databrick_workspace.managed_resource_group_id
}
output "public_ip_address" {
  value = azurerm_public_ip.nat_publicip.ip_address
}

output "test_storage_account" {
  value = azurerm_storage_account.az_stor.name
}

output "test_storage_container" {
  value = azurerm_storage_container.az_stor.name
}

output "test_event_hub_namespace" {
  value  = azurerm_eventhub_namespace.mdp_hubns.name
}

output "cloud_env" {
  value = "azure"
}
