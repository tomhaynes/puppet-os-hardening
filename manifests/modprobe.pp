# === Copyright
#
# Copyright 2014, Deutsche Telekom AG
# Licensed under the Apache License, Version 2.0 (the "License");
# http://www.apache.org/licenses/LICENSE-2.0
#

# == Class: os_hardening::profile
#
# Configures modprobe.conf.
#
class os_hardening::modprobe ()
{

    file { '/etc/modprobe.d/modprobe.conf':
      ensure => file,
      source => 'puppet:///modules/os_hardening/modprobe.conf',
      owner  => 'root',
      group  => 'root',
      mode   => '0600',
    }

}
