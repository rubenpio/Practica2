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

# Creación de máquina virtual (VM) con sistema operativo Linux
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_name
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Basic_A1"
  admin_username                  = var.admin_username
  disable_password_authentication = true

# Configuramos la ruta donde sacará la calve pública para poder conectar con la VM
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }
# Seleccionamos una interfaz de red creada anteriormente
  network_interface_ids = ["/subscriptions/ea75ca59-207c-4e10-bc03-dc481f4cd005/resourceGroups/federico/providers/Microsoft.Network/networkInterfaces/Interface1"]
# Escogemos el tamaño y caracteristicas que va a tener el dico de la maquina
  os_disk {
    disk_size_gb         = 32
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
# Espeficificamos la imagen origen que se utilizará para crear la maquina
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
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
    vm_size         = "Basic_A1"
    os_disk_size_gb = 10
  }
  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }
  tags = {
    Environment = "Production"
  }
}



