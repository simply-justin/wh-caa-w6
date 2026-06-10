# Docker host role

Deze zelfgemaakte Ansible role installeert Docker op Ubuntu hosts. De role wordt gebruikt op de Azure VM en de ESXi VM in de week 6 hybrid cloud deployment.

## Variabelen

- `docker_packages`: packages die nodig zijn voor Docker.
- `docker_service_name`: naam van de Docker service.
- `docker_users`: gebruikers die lid worden van de Docker group.

## Voorbeeld

```yaml
- name: Configure Docker hosts
  hosts: hybrid
  become: true
  roles:
    - docker_host
```

## Galaxy

De role bevat `meta/main.yml` en kan als aparte GitHub repository worden gepubliceerd, bijvoorbeeld als `ansible-role-docker-host`. Daarna kan de role via `ansible-galaxy install -r ansible/requirements.yml -p ansible/galaxy_roles` worden geinstalleerd.
