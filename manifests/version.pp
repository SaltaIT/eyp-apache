class apache::version {

  case $::osfamily {
    'RedHat': {
      if ($::operatingsystem == 'Amazon') {
        $default = '2.2'
      } elsif ($::operatingsystem == 'Fedora' and versioncmp($distrelease, '18') >= 0) or ($::operatingsystem != 'Fedora' and versioncmp($distrelease, '7') >= 0) {
        $default = '2.4'
      } else {
        $default = '2.2'
      }
    }
    'Debian': {
      if $::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '13.10') >= 0 {
        $default = '2.4'
      } elsif $::operatingsystem == 'Debian' and versioncmp($distrelease, '8') >= 0 {
        $default = '2.4'
      } else {
        $default = '2.2'
      }
    }
    'Suse': {
      $default = '2.2'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily}")
    }
  }
}
