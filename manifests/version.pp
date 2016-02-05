class apache::version {

  $osr_array = split($::operatingsystemrelease,'[\/\.]')
  $distrelease = $osr_array[0]
  if ! $distrelease {
    fail("unparsable \$::operatingsystemrelease: ${::operatingsystemrelease}")
  }

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
