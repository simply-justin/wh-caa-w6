[azure]
${azure_vm_name} ansible_host=${azure_public_ip} ansible_user=${ansible_user} ansible_ssh_private_key_file=${azure_ssh_private_key_path} cloud_provider=azure container_image=${container_image} container_name=${container_name}

[esxi]
${esxi_vm_name} ansible_host=${esxi_host_ip} ansible_user=${ansible_user} ansible_ssh_private_key_file=${esxi_ssh_private_key_path} cloud_provider=esxi container_image=${container_image} container_name=${container_name} testuser_private_key_file=${testuser_private_key} testuser_public_key_file=${testuser_public_key} azure_ssh_host=${azure_public_ip}

[hybrid:children]
azure
esxi

[hybrid:vars]
testuser_name=testuser
