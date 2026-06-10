output "azure_public_ip" {
  description = "Publiek IP-adres van de Azure VM."
  value       = local.azure_public_ip
}

output "esxi_vm_ip" {
  description = "IP-adres van de ESXi VM voor Ansible."
  value       = local.esxi_host_ip
}

output "testuser_private_key_path" {
  description = "Lokale private key waarmee testuser vanaf de ESXi VM naar Azure kan inloggen."
  value       = local_sensitive_file.testuser_private_key.filename
  sensitive   = true
}

output "ansible_inventory_path" {
  description = "Inventory naast ansible/group_vars."
  value       = local_file.ansible_inventory.filename
}

output "terraform_inventory_path" {
  description = "Inventory in de Terraform root."
  value       = local_file.terraform_inventory.filename
}
