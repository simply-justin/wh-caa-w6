# Testuser role

Deze role maakt op de Azure VM en ESXi VM de gebruiker `testuser` aan. Terraform genereert een SSH keypair. Ansible plaatst de public key op beide systemen en zet de private key alleen op de ESXi VM.

Daardoor kan `testuser` vanaf de ESXi VM naar de Azure VM inloggen:

```bash
ssh testuser@<azure-public-ip>
```
