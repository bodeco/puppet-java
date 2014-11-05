# Class: Oracle Java Installation for MS Windows and for RHEL family.
#
class java (
  $dist    = 'jre',
  $version = 7,
  $build   = 19,
  $update  = 60,
  $url     = 'http://download.oracle.com/otn-pub/java/jdk',
) {
  include 'archive::staging'

  case $::osfamily {
    'RedHat': {
      $file_suffix     = 'linux-x64.rpm'
      $rpm_ver         = "2000:1.${version}.0_${build}-fcs"
      $provider        = rpm
      $install_options = undef
      $staging_path    = '/opt/staging'
      $package_name    = $dist
      $mode            = '0644'
    }
    'Windows': {
      $file_suffix     = 'windows-x64.exe'
      $rpm_ver         = undef
      $provider        = windows
      $install_options = '/s'
      $staging_path    = $::staging_windir
      $package_name    = "Java ${version} Update ${update} (64-bit)"
      $mode            = '0740'
    }
    default: {
      $file_suffix     = 'linux-x64.rpm'
      $rpm_ver         = "2000:1.${version}.0_${build}-fcs"
      $provider        = rpm
      $install_options = undef
      $staging_path    = '/opt/staging'
      $package_name    = $dist
      $mode            = '0644'
    }
  }

  $artifact_name = "${dist}-${version}u${update}-${file_suffix}"
  $source = "${url}/${version}u${update}-b${build}/${artifact_name}"
  $local_artifact_file = "${staging_path}/${artifact_name}"

  # http://stackoverflow.com/questions/10268583/how-to-automate-download-and-installation-of-java-jdk-on-linux
  archive { $local_artifact_file:
    source  => $source,
    cleanup => false,
    cookie  => 'oraclelicense=accept-securebackup-cookie',
  }

  file { $local_artifact_file:
    mode    => $mode,
    require => Archive[$local_artifact_file],
  }

  package { $package_name:
    ensure          => present,
    install_options => $install_options,
    source          => $local_artifact_file,
    provider        => $provider,
    require         => File[$local_artifact_file],
  }

  # Post installation steps.
  if $::osfamily != 'Windows'
  {
    exec { 'java_alternatives':
      command     => 'alternatives --install /usr/bin/java java /usr/java/latest/bin/java 100',
      path        => $::path,
      refreshonly => true,
      subscribe   => Package[$package_name],
    }
  }
}
