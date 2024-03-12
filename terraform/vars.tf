variable "resource_group_name" {
  description = "Nombre del grupo de recursos de Azure"
}

variable "location" {
  description = "Ubicación del recurso en Azure"
}

variable "acr_name" {
  description = "Nombre del ACR"
}

variable "vm_name" {
  description = "Nombre de la máquina virtual"
}

variable "admin_username" {
  description = "Nombre de usuario para acceder a la máquina virtual"
}

variable "ssh_public_key_path" {
  description = "Ruta al archivo de clave pública SSH"
}

variable "aks_cluster_name" {
  description = "Nombre del clúster de AKS"
}

variable "aks_dns_prefix" {
  description = "Prefijo DNS para el clúster de AKS"
}

variable "vnet_name" {
  description = "Nombre de la red virtual"
}

variable "subnet_name" {
  description = "Nombre de la subred"
}

variable "nic_name" {
  description = "Nombre de la interfaz de red"
}

variable "ip_pub" {
  description = "Nombre de la ip pública"
}


