# === Copyright
#
# Copyright 2014, Deutsche Telekom AG
# Licensed under the Apache License, Version 2.0 (the "License");
# http://www.apache.org/licenses/LICENSE-2.0
#

# == Class: os_hardening::minimize_access
#
# Configures profile.conf.
#
class os_hardening::minimize_access (
  $allow_change_user   = false,
  $always_ignore_users =
    ['root','sync','shutdown','halt'],
  $ignore_users        = [],
) {

  # from which folders to remove public access
  $folders = [
    '/usr/local/sbin',
    '/usr/sbin',
    '/usr/bin',
    '/sbin',
    '/bin',
  ]

  # remove write permissions from path folders ($PATH) for all regular users
  # this prevents changing any system-wide command from normal users
  file { $folders:
    ensure  => directory,
    links   => follow,
    mode    => 'go-w',
    recurse => true,
  }

  # shadow must only be accessible to user root
  case $::operatingsystem {
    'debian', 'ubuntu', 'opensuse', 'sles': {
      $shadowgroup = 'shadow'
      $shadowmode  = '0640'
    }
    'RedHat','CentOS': {
      $shadowgroup = 'root'
      $shadowmode  = '0000'
    }
    default: {
      $shadowgroup = 'root'
      $shadowmode  = '0600'
    }
  }

  file { '/etc/shadow':
    ensure => file,
    owner  => 'root',
    group  => $shadowgroup,
    mode   => $shadowmode,
  }

  # su must only be accessible to user and group root
  if $allow_change_user == false {
    file { '/bin/su':
      ensure => file,
      links  => follow,
      owner  => 'root',
      group  => 'root',
      mode   => '0750',
    }
  } else {
    file { '/bin/su':
      ensure => file,
      links  => follow,
      owner  => 'root',
      group  => 'root',
      mode   => '4755',
    }
  }

  # retrieve system users through custom fact
  $system_users = split($::retrieve_system_users, ',')

  # build array of usernames we need to verify/change
  $ignore_users_arr = union($always_ignore_users, $ignore_users)

  # build a target array with usernames to verify/change
  $target_system_users = difference($system_users, $ignore_users_arr)

  # ensure accounts are locked (no password) and use nologin shell
  user { $target_system_users:
    ensure   => present,
    shell    => '/usr/sbin/nologin',
    password => '*',
  }

}

