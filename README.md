# Terraforming the infrastructure

## Devops
- no flakey services
- version control of infra structure
- automation

## Terraform benefits

- bird's eye view of the infrastructure
- track changes
- easily setup multiple environments from single infrastructure definition 
- maintain multicloud and/or on-premise infrastructure
- track the state of infrastructure - file, s3, consul
    - resource based locking allows multipe users to make changes to the infrastructure without affecting each other.

## Terraform components and features

- HCL syntax based files
    - string interpolation
    - input and output variables
        - passed from commandline
        - tfvars file
- Providers
    - AWS, DigiOcean, F5, Azure, vSphere
    - multi provider support
- Resources
    - machines, loadbalancers, etc
- Data blocks
    - fetch data from providers
- States
    - shared
    - tracked
- Provisioners for VMs
    - act on resource after it's created
    - chef support is builtin
    - run bash scripts on remote machine or local
        - trigger ansible locally to continue setting up the machine
    - runs only on new VMs (tainting the infrastructure allows you to recreate)
- Parallel provisioning
- Secure
    - keys and other sensitive data can be stored in Vault

## Demo

- providers & resources & output variables
- provisioners
- create index.html template page
- use file provisioning to deploy different index.html pages on the servers
- setup loadbalancer / setup distributed dns

### Notes

1. digital ocean images ubuntu-16-04-x64
2. digital ocean DCs - ams2, ams3, lon1, fra1

### Demo 1

1. setup tf file with digital ocean
1. create droplet
1. add ssh key
1. add output variable to show IP Addresses
1. logon using ssh
1. create multiple machines
1. 