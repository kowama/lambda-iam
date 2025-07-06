# IAM Lab VM Setup using Vagrant + Ansible

## Vagrant Setup Windows

### Installation

1. Install [Vagrant](https://www.vagrantup.com/downloads)
2. Install [VMware Workstation Pro](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion)
3. Install [Vagrant VMware plugin](https://developer.hashicorp.com/vagrant/docs/providers/vmware/installation)
4. Install [Vagrant VMware Utility](https://developer.hashicorp.com/vagrant/install/vmware)

### Configuration

1. Clone this repository to your local machine.
2. Open a terminal and navigate to the cloned repository directory.
3. Run the following command to initialize the Vagrant environment:

    ```bash
    vagrant box add rockylinux/9 --provider=vmware_desktop
    vagrant up
    ```

### Login to the VM

1. After the VMs are up, you can SSH into the VM using:

    ```bash
    vagrant ssh vm1
    ```

## Ansible Setup

1. Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
