class monit::install {

  if $caller_module_name != $module_name {
    warning("${name} is not part of the public API of the ${module_name} module and should not be directly included in the manifest.")
  }

  if $monit::package == "monit" {
    package { $monit::package:
      ensure => present,
    }
  }
  else {
    # custom version supplies, which means we need to download custom version of monit
    # and install it over the package
    # we still use package to have all nice service/logrotate/etc benefits

    case $facts['os']['family'] {
      /Debian|RedHat/: { $family = "linux" }
    }

    case $facts['os']['architecture'] {
      'x86_64': { $arch = 'x64' }
      default:  { $arch = 'x86' }
    }

    $url = case $monit::package {
      /^http.*monit-([^-]*)-/: { $version = $1
                                 $monit::package }
      default: { $version = $monit::package
                 "https://mmonit.com/monit/dist/binary/$version/monit-$version-$family-$arch.tar.gz"
                }
    }

    package { 'monit':
      ensure => present,
    } ->
    exec {'link new conf file location':
      command => '/bin/ln -s /etc/monit.conf /etc/monitrc',
      creates => '/etc/monitrc'
    } ->
    file {'/opt/monit':
      ensure => directory
    } ->
    file {'/usr/bin/monit':
      ensure => link,
      target => "/opt/monit/monit-$version/bin/monit",
    }
  }
}

