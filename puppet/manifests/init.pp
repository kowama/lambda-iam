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
    $ldap_home = '/opt/iam/ldap'

    user { $ldap_admin:
        ensure     => present,
        home       => $ldap_admin_home,
        managehome => yes,
        shell      => '/bin/bash',
        password   => '$6$Uc6S.mBIw3fAaLbp$fT0P0MlS/TN.1IVOfN7nm8flp.TpLs7tILvlJfNmUraOhiKRoynCprpq53yyTBfeMI.dnjOOCoQw8c8vCK.4v1',
    }

    file { $ldap_admin_home:
        ensure  => directory,
        owner   => $ldap_admin,
        group   => $ldap_admin,
        mode    => '0755',
        recurse => true,
    }
    file { $ldap_home :
        ensure  => directory,
        owner   => $ldap_admin,
        group   => $ldap_admin,
        mode    => '0755',
        recurse => true,
    }

}
