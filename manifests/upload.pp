# Definition: rsync::put
#
# put files via rsync
#
# Parameters:
#   $source        - source to copy from
#   $path          - path to copy to, defaults to $name
#   $user          - username on remote system
#   $purge         - if set, rsync will use '--delete'
#   $exlude        - string (or array) to be excluded
#   $include       - string (or array) to be included
#   $exclude_first - if 'true' then first exclude and then include; the other way around if 'false'
#   $keyfile       - path to ssh key used to connect to remote host, defaults to /home/${user}/.ssh/id_rsa
#   $timeout       - timeout in seconds, defaults to 900
#
# Actions:
#   put files via rsync
#
# Requires:
#   $source must be set
#
# Sample Usage:
#
#  rsync::put { '${rsyncDestHost}:/repo/foo':
#    user    => 'user',
#    source  => "/repo/foo/",
#  } # rsync
#
define openvpn::upload (
  $path          = undef,
  $timeout       = '900',
  $bucket,
) {

  if $path {
    $source = $path
  } else {
    $source = $name
  }

  $s3cmd_options = join(
    delete_undef_values([$options, $mypurge, $excludeandinclude, $myuseropt, $source, "${myuser}${mypath}"]), ' ')

  exec { "s3cmd ${name}":
    command => "s3cmd put $source s3://${bucket}/",
    path    => [ '/bin', '/usr/bin' ],
    # perform a dry-run to determine if anything needs to be updated
    # this ensures that we only actually create a Puppet event if something needs to
    # be updated
    # TODO - it may make senes to do an actual run here (instead of a dry run)
    #        and relace the command with an echo statement or something to ensure
    #        that we only actually run rsync once
    # onlyif  => "test `rsync --dry-run --itemize-changes ${rsync_options} | wc -l` -gt 0",
    #     s3cmd put FILE [FILE...] s3://BUCKET[/PREFIX]

    timeout => $timeout,
  }
}
