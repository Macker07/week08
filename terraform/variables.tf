variable "location" {
  description = "Azure region in which resources are created."
  type        = string
  default     = "Australia East"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group."
  type        = string
}

variable "acr_name" {
  description = "Globally unique Azure Container Registry name."
  type        = string

  validation {
    condition     = length(var.acr_name) >= 5 && length(var.acr_name) <= 50 && can(regex("^[a-zA-Z0-9]+$", var.acr_name))
    error_message = "ACR name must contain 5-50 alphanumeric characters."
  }
}

variable "storage_account_name" {
  description = "Globally unique Azure Storage Account name."
  type        = string

  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24 && can(regex("^[a-z0-9]+$", var.storage_account_name))
    error_message = "Storage Account name must contain 3-24 lowercase letters and numbers."
  }
}

variable "aks_cluster_name" {
  description = "Name of the Azure Kubernetes Service cluster."
  type        = string
}

variable "aks_dns_prefix" {
  description = "DNS prefix used by AKS."
  type        = string
  default     = "koalatech"
}

variable "aks_node_count" {
  description = "Number of nodes in the AKS default node pool. Task 8.1P requires three."
  type        = number
  default     = 3

  validation {
    condition     = var.aks_node_count == 3
    error_message = "Task 8.1P requires exactly three AKS nodes."
  }
}

variable "aks_node_vm_size" {
  description = "Virtual machine size for AKS nodes."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "kubernetes_version" {
  description = "Optional AKS Kubernetes version. Null selects Azure's current default."
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment label applied to Azure resource tags."
  type        = string
  default     = "task-8.1p"
}

variable "tags" {
  description = "Tags applied to Azure resources."
  type        = map(string)
  default = {
    Project   = "KoalaTech Course Platform"
    ManagedBy = "Terraform"
    Practical = "Week08"
  }
}
