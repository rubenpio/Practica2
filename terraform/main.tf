# Configuración del proveedor Azure
provider "azurerm" {
  features {}
}

# Creación de grupo de recursos
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Creación de Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                     = var.acr_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = "Basic"
}

# Recurso de Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.aks_dns_prefix

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_DS2_v2"
    os_disk_size_gb = 30
  }
  identity {
    type = "SystemAssigned"
  }
  tags = {
    Environment = "Production"
  }
  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet"
  }
}

# Asignación de roles para permitir que AKS acceda a ACR
resource "azurerm_role_assignment" "aks_acr_role_assignment" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check= true
}

# Creación de la red virtual
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

# Creación de un subred
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
# Creación de una dirección IP pública
resource "azurerm_public_ip" "public_ip" {
  name                = var.ip_pub
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"  # Puedes cambiar a "Static" si necesitas una IP pública estática
}
# Creación de una interfaz de red
resource "azurerm_network_interface" "interface" {
  name                = var.nic_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}
# Creación de máquina virtual (VM) con sistema operativo Linux
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_name
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_DS1_v2"
  admin_username                  = var.admin_username
  disable_password_authentication = true

# Configuramos la ruta donde sacará la calve pública para poder conectar con la VM
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }
# Seleccionamos una interfaz de red creada anteriormente
  network_interface_ids = [azurerm_network_interface.interface.id]
# Escogemos el tamaño y caracteristicas que va a tener el dico de la maquina
  os_disk {
    disk_size_gb         = 32
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
# Espeficificamos la imagen origen que se utilizará para crear la maquina
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

}
