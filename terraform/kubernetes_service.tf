resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_cluster_name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_prefix          = var.aks_dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name       = "nodepool1"
    node_count = var.aks_node_count
    vm_size    = var.aks_node_vm_size

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, { Environment = var.environment })

  # This cluster was created before it was imported into Terraform. Preserve
  # its generated administrator/SSH profile instead of replacing the cluster.
  lifecycle {
    ignore_changes = [linux_profile]
  }
}

# Allow the AKS kubelet identity to pull the private application images.
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.main.id
}
