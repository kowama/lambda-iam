#!/bin/bash
# Puppet fact for IAM Server environment

## LDAP Facts

# YAML Header
echo "---"
# if ldap instance is installed
[ -f /opt/iam/ldap/instance/bin/status ] &&  /opt/iam/ldap/instance/bin/status -V | grep -q "Build" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "ldap_instance_installed: true"
else
    echo "ldap_instance_installed: false"
fi

# Base DN
echo 'base_dn: dc=lambda,dc=corp'