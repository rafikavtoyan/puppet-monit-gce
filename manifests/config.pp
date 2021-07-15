class monit::config {

  if $caller_module_name != $module_name {
    warning("${name} is not part of the public API of the ${module_name} module and should not be directly included in the manifest.")
  }

  # Monit conf file and directory.
  validate_absolute_path($monit::conf_file)
  file { $monit::conf_file:
    ensure  => present,
    content => template('monit/conf_file.erb'),
  }
  validate_absolute_path($monit::conf_dir)
  file { $monit::conf_dir:
    ensure  => directory,
    recurse => true,
    purge   => $monit::conf_purge,
  }

  # Monit configuration options for the tpl.
  #$logfile may be some as "syslog facility log_daemon"
  # so validating abs path is inacurate.
  # validate_absolute_path($monit::logfile)
  if $monit::idfile {
    validate_absolute_path($monit::idfile)
  }
  if $monit::statefile {
    validate_absolute_path($monit::statefile)
  }
  validate_bool($monit::eventqueue)
  validate_array($monit::alerts)
  validate_bool($monit::httpserver)
  validate_bool($monit::httpserver_ssl)
  if $monit::httpserver_ssl {
    validate_absolute_path($monit::httpserver_pemfile)
  }
  validate_array($monit::httpserver_allow)
  file { "${monit::conf_dir}/00_monit_config":
    ensure  => present,
    content => template('monit/conf_file_overrides.erb'),
  }
  
  # Additional checks.
  if ($monit::hiera_merge_strategy == 'hiera_hash') {
    $mychecks = hiera_hash('monit::checks', {})
  }
  else {
    $mychecks = $monit::checks
  }
  validate_hash($mychecks)
  create_resources('monit::check', $mychecks)
}

