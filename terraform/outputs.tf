output "resource_group_name" {
  value = data.azurerm_resource_group.main.name
}

output "acr_name" {
  value = azurerm_container_registry.main.name
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "storage_connection_string" {
  description = "Store this as AZURE_STORAGE_CONNECTION_STRING in both GitHub environments."
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "aks_get_credentials_command" {
  value = "az aks get-credentials --resource-group ${data.azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name} --overwrite-existing"
}
