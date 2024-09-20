# Puppet Lambda IAM Directory

Lambda Corp IAM Directory puppet module.

## Prerequisites

### Files

- Ensure `puppet/ldap-pp/files/sources/PingDirectory.zip` contains the latest zip file of PingDirectory
- Ensure `puppet/ldap-pp/files/Pingdirectory.lic` is updated with the license key

### Master Node

- Setup Puppet Master Node on RHEL 9 based system

  ```bash
    sudo dnf install -y https://yum.puppet.com/puppet8-release-el-9.noarch.rpm
    sudo dnf install -y puppetserver
    sudo systemctl start puppetserver
    sudo systemctl enable puppetserver
  ```

- Set master hostname

  ```bash
   sudo hostnamectl set-hostname iam.lambda.corp
  ```

### Agent Node

- Setup Puppet Agent Node on RHEL 9 based system

  ```bash
    sudo dnf install -y https://yum.puppet.com/puppet8-release-el-9.noarch.rpm
    sudo dnf install -y puppet-agent
    sudo systemctl start puppet
    sudo systemctl enable puppet
  ```

- Configure agent to connect to master

  ```bash
    puppet config set server iam.lambda.corp
  ```

- Puppet Master: Sign the Agent's Certificate

  ```bash
    sudo puppetserver ca list
    sudo puppetserver ca sign --certname agent.lambda.corp
  ```

## Setup

## Usage

- Install the module on the Puppet Master Node

  ```bash
  sudo mkdir -p /etc/puppetlabs/code/environments/production/modules/iam/
  sudo cp -r ldap-pp/* /etc/puppetlabs/code/environments/production/modules/iam/
  ```

- create site.pp file in /etc/puppetlabs/code/environments/production/manifests/site.pp
  
  ```ruby
  node default {
    include iam::pingdirectory
  }
  ```

- Run Puppet Agent on the Agent Node

  ```bash
  puppet agent -t
  ```
