#===============================================================================
# Class Name: iam::pingdirectory
# Description: This class is responsible for managing the Lambda Corp LDAP directory
# Author: Kowama
# Date: 2024-09-08
#===============================================================================
# Example usage:
#   include iam::pingdirectory
#   puppet apply -e 'include iam::pingdirectory'
#===============================================================================
# Parameters:
#   $param1: <Description of parameter 1>
#   $param2: <Description of parameter 2>
#==============================================
class iam::pingdirectory {

    $ldap_admin = 'ping'
    $ldap_admin_home = '/opt/iam'
    $tmp_dir = "${ldap_admin_home}/tmp"
    $ldap_home = "${ldap_admin_home}/ldap"
    $ldap_instance_dir = "${ldap_home}/instance"
    $ldap_instance_installed= $facts['ldap_instance_installed']
    $pingdirectory_zip_file = 'PingDirectory.zip'
    $base_dn = $facts['base_dn'] ? {
        undef => 'dc=lambda,dc=corp',
        default => $facts['base_dn'],
    }

    notify { 'Running PingDirectory class':
        message => '=== Running LDAP - PingDirectory class ===',
    }

    notify { "LDAP Instance BASE_DN: ${base_dn}":
        message => "+++ LDAP Instance BASE_DN: ${base_dn} +++",
    }

    if $ldap_instance_installed {
        notify { 'LDAP instance already installed':
            message => '+++ LDAP instance already installed +++',
        }
    } else {
        notify { 'LDAP instance not installed':
            message => '+++ LDAP instance not installed +++',
        }
    }

    ## ----
    ## LDAP Admin User Account
    ## ----

    user { $ldap_admin:
        ensure     => present,
        home       => $ldap_admin_home,
        managehome => yes,
        shell      => '/bin/bash',
        password   => '$6$Uc6S.mBIw3fAaLbp$fT0P0MlS/TN.1IVOfN7nm8flp.TpLs7tILvlJfNmUraOhiKRoynCprpq53yyTBfeMI.dnjOOCoQw8c8vCK.4v1',
        #password is 'Ping@2024'
    }

    file { $ldap_admin_home:
        ensure    => directory,
        owner     => $ldap_admin,
        group     => $ldap_admin,
        mode      => '0755',
        max_files => 5000,
        recurse   => true,
    }
    file { $ldap_home :
        ensure    => directory,
        owner     => $ldap_admin,
        group     => $ldap_admin,
        mode      => '0755',
        max_files => 5000,
        recurse   => true,
    }
    file { $ldap_instance_dir:
        ensure    => directory,
        owner     => $ldap_admin,
        group     => $ldap_admin,
        mode      => '0755',
        max_files => 5000,
        recurse   => true,
    }

    file { $tmp_dir:
        ensure    => directory,
        owner     => $ldap_admin,
        group     => $ldap_admin,
        mode      => '0755',
        max_files => 5000,
        recurse   => true,
    }

    ## ----
    ## PingDirectory Installation Prerequisites
    ## ----
    file { '/etc/security/limits.d/90-pingdirectory.conf':
        ensure  => 'file',
        mode    => '0644',
        content => template('iam/90-pingdirectory.conf.erb'),
    }

    package { 'java-17-openjdk':
        ensure => installed,
    }

    package { 'unzip':
        ensure => installed,
    }

    # Ensure swap is turned off
    exec { 'disable_swap':
        command => '/sbin/swapoff -a',
        path    => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
        unless  => '/usr/sbin/swapon --show | grep -q "swap"',
    }
    # Ensure swap is removed from /etc/fstab
    augeas { 'remove_swap_fstab':
        context => '/files/etc/fstab',
        changes => ['rm *[file="/swap"]'],
        onlyif  => 'match *[file="/swap"] size > 0',
        require => Exec['disable_swap'],
    }

    ## Environment Variables
    file { '/etc/profile.d/env.sh':
        ensure  => 'file',
        mode    => '0644',
        content => template('iam/env.sh.erb'),
    }

    ## ----
    ## PingDirectory Installation
    ## ----

    # PingDirectory License
    file { "${ldap_instance_dir}/Pingdirectory.lic":
        ensure  => file,
        owner   => $ldap_admin,
        group   => $ldap_admin,
        mode    => '0644',
        content => file('iam/Pingdirectory.lic'),
    }
    # Secret and Passwords
    file { "${ldap_instance_dir}/.sec":
        ensure => directory,
        owner  => $ldap_admin,
        group  => $ldap_admin,
        mode   => '0700',
    }
    file { "${ldap_instance_dir}/.sec/keystore.pin":
        ensure  => file,
        owner   => $ldap_admin,
        group   => $ldap_admin,
        mode    => '0600',
        content => file('iam/conf/keystore.pin'),
    }
    file { "${ldap_instance_dir}/.sec/admin.pw":
        ensure  => file,
        owner   => $ldap_admin,
        group   => $ldap_admin,
        mode    => '0600',
        content => file('iam/conf/admin.pw'),
    }
    file { "${ldap_instance_dir}/.sec/encryption-settings.pw":
        ensure  => file,
        owner   => $ldap_admin,
        group   => $ldap_admin,
        mode    => '0600',
        content => file('iam/conf/encryption-settings.pw'),
    }


    if(!$ldap_instance_installed) {
        notify { 'Installing PingDirectory':
            message => '=== Installing PingDirectory ===',
        }

        notify { 'Copying PingDirectory source file':
            message => '--- Copying PingDirectory source file ---',
        }

        file { "${tmp_dir}/${pingdirectory_zip_file}":
            ensure => present,
            source => "puppet:///modules/iam/sources/${pingdirectory_zip_file}",
        }

        exec { 'Extract PingDirectory zip archive':
            command => "unzip ${tmp_dir}/${pingdirectory_zip_file} -d ${tmp_dir}/",
            user    => $ldap_admin,
            path    => ['/usr/bin', '/bin'],
            require => Package['unzip'],
        }
        exec { 'Move PingDirectory to installation directory':
            command => "mv ${tmp_dir}/PingDirectory/* ${ldap_instance_dir}",
            user    => $ldap_admin,
            path    => ['/usr/bin', '/bin'],
        }
        exec { 'Set ownership of PingDirectory installation directory':
            command => "chown -R ${ldap_admin}:${ldap_admin} ${ldap_home}",
            path    => ['/usr/bin', '/bin'],
        }

        exec { "Remove ${tmp_dir} directory contents":
            command => "rm -rf ${tmp_dir}/*",
            path    => ['/usr/bin', '/bin'],
        }

        notify { 'Setup PingDirectory Instance installation':
            message => '--- Setup PingDirectory Instance installation ---',
        }

        # cd to ldap admin home
        exec { 'cd to ldap admin home':
            command => "cd ${ldap_admin_home}",
            path    => ['/usr/bin', '/bin'],
        }


        exec { 'Setup PingDirectory Instance':
            command => "${ldap_instance_dir}/setup --no-prompt \
                --licenseKeyFile ${ldap_instance_dir}/Pingdirectory.lic \
                --baseDN ${base_dn} --sampleData 200 \
                --localHostName $(hostname) --ldapPort 1389 --skipHostnameCheck \
                --rootUserDN cn=dManager \
                --rootUserPasswordFile ${ldap_instance_dir}/.sec/admin.pw --allowWeakRootUserPassword \
                --maxHeapSize 768m --primeDB --doNotStart --ldapsPort 1636 \
                --httpsPort 8443 --instanceName iam-pds-eu-01 --location eu \
                --optionCacheDirectory ${ldap_instance_dir}/logs/option-cache \
                --enableStartTLS --generateSelfSignedCertificate \
                --encryptDataWithPassphraseFromFile ${ldap_instance_dir}/.sec/encryption-settings.pw \
                --populateToolPropertiesFile bind-password --acceptLicense",
            user    => $ldap_admin,
            path    => ['/usr/bin', '/bin'],
            cwd     => $ldap_instance_dir,
            require => Exec['Move PingDirectory to installation directory'],
        }

        exec { 'Start PingDirectory':
            command => "${ldap_instance_dir}/bin/start-server",
            user    => $ldap_admin,
            path    => ['/usr/bin', '/bin'],
            cwd     => $ldap_instance_dir,
            require => Exec['Setup PingDirectory Instance'],
        }

        notify { 'PingDirectory installed successfully':
            message => '\e[32m+++ PingDirectory installed successfully +++\e[0m',
        }
    }

}


