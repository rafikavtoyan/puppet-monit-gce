# == Defined type: monit::check::program
#
# Implement Monit's CHECK PROGRAM
#
define monit::check::program(
  # Check type specific.
  $path,
  $template   = 'monit/check/program.erb',

  # Common parameters.
  $ensure     = present,
  $group      = $name,
  $alerts     = [],
  $noalerts   = [],
  $tests      = [],
  $depends    = [],
  $priority   = '20',
  $bundle     = $name,
  $order      = 0,
  $program_start   = undef,
  $program_stop    = undef,
  $uid             = undef,
  $gid             = undef,
  $timeout         = undef,
  $timeout_start   = undef,
  $timeout_stop    = undef,
) {

  $path_parts = split($path, ' ')
  validate_absolute_path($path_parts[0])

  if $timeout {
    $real_timeout_start   = pick($timeout_start, $timeout)
    $real_timeout_stop    = pick($timeout_stop, $timeout)
  }

  monit::check::instance { "${name}_instance":
    ensure   => $ensure,
    name     => $name,
    type     => 'program',
    header   => template($template),
    group    => $group,
    alerts   => $alerts,
    noalerts => $noalerts,
    tests    => $tests,
    depends  => $depends,
    priority => $priority,
    bundle   => $bundle,
    order    => $order,
  }
}

