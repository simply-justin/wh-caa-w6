variable "project_name" {
  description = "Naam voor gedeelde resources."
  type        = string
  default     = "caa-week6-hybrid"
}

variable "azure_resource_group_name" {
  description = "Naam van de Azure resource group."
  type        = string
  default     = "s1203559"
}

variable "azure_vnet_cidr" {
  description = "CIDR range voor het Azure virtual network."
  type        = string
  default     = "10.60.0.0/16"
}

variable "azure_subnet_cidr" {
  description = "CIDR range voor het Azure subnet."
  type        = string
  default     = "10.60.1.0/24"
}

variable "azure_vm_name" {
  description = "Naam van de Azure VM."
  type        = string
  default     = "week6-azure-vm"
}

variable "azure_vm_size" {
  description = "Grootte van de Azure VM."
  type        = string
  default     = "Standard_B1s"
}

variable "allowed_source_address_prefix" {
  description = "Bronadres dat SSH en HTTP naar de Azure VM mag gebruiken. Gebruik in productie een specifiek IP-adres."
  type        = string
  default     = "*"
}

variable "esxi_hostname" {
  description = "Hostname of IP-adres van de ESXi-server."
  type        = string
  default     = "192.168.1.69"
}

variable "esxi_hostport" {
  description = "SSH-poort van de ESXi-server."
  type        = string
  default     = "22"
}

variable "esxi_hostssl" {
  description = "HTTP-poort van de ESXi-server voor provider uploads."
  type        = string
  default     = "80"
}

variable "esxi_username" {
  description = "Gebruikersnaam voor ESXi."
  type        = string
  default     = "root"
}

variable "esxi_password" {
  description = "Wachtwoord voor ESXi. Gebruik hiervoor TF_VAR_esxi_password of een CI/CD secret."
  type        = string
  sensitive   = true
}

variable "esxi_vm_name" {
  description = "Naam van de ESXi VM."
  type        = string
  default     = "week6-esxi-vm"
}

variable "esxi_vm_ip" {
  description = "IP-adres van de ESXi VM voor Ansible. Laat leeg om provideroutput te gebruiken."
  type        = string
  default     = "192.168.1.61"
}

variable "esxi_disk_store" {
  description = "ESXi datastore waarop de VM wordt geplaatst."
  type        = string
  default     = "datastore1"
}

variable "esxi_guestos" {
  description = "Guest OS type voor de ESXi VM."
  type        = string
  default     = "ubuntu-64"
}

variable "esxi_memsize" {
  description = "Geheugen voor de ESXi VM in MB."
  type        = number
  default     = 1024
}

variable "esxi_numvcpus" {
  description = "Aantal vCPU's voor de ESXi VM."
  type        = number
  default     = 1
}

variable "esxi_virtual_network" {
  description = "Naam van het ESXi netwerk."
  type        = string
  default     = "VM Network"
}

variable "esxi_nic_type" {
  description = "Type netwerkkaart voor de VM."
  type        = string
  default     = "vmxnet3"
}

variable "ansible_user" {
  description = "Beheeruser waarmee Ansible via SSH inlogt."
  type        = string
  default     = "ubuntu"
}

variable "azure_ssh_public_key_path" {
  description = "Pad naar de publieke Azure SSH-key voor de beheeruser."
  type        = string
  default     = "~/.ssh/azure.pub"
}

variable "azure_ssh_private_key_path" {
  description = "Pad naar de private Azure SSH-key die Ansible gebruikt."
  type        = string
  default     = "~/.ssh/azure"
}

variable "esxi_ssh_public_key_path" {
  description = "Pad naar de publieke Skylab SSH-key voor de ESXi VM."
  type        = string
  default     = "~/.ssh/skylab.pub"
}

variable "esxi_ssh_private_key_path" {
  description = "Pad naar de private Skylab SSH-key die Ansible gebruikt."
  type        = string
  default     = "~/.ssh/skylab"
}

variable "container_image" {
  description = "Docker image die op beide VM's moet draaien."
  type        = string
  default     = "ghcr.io/simply-justin/wh-caa-w6/hello-world-hybrid:latest"
}

variable "container_name" {
  description = "Naam van de Hello World container."
  type        = string
  default     = "hello-world-hybrid"
}
