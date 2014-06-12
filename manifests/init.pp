# Class: Oracle Java Installation for RHEL family
#
class java (
  $dist    = 'jre',
  $version = 7,
  $build   = 19,
  $update  = 60,
  $url     = 'http://download.oracle.com/otn-pub/java/jdk',
  $path    = '/opt/java',
) {

  #http://download.oracle.com/otn-pub/java/jdk/7u60-b19/jdk-7u60-linux-x64.rpm
  #http://download.oracle.com/otn-pub/java/jdk/7u55-b13/jre-7u55-linux-x64.rpm

  $rpm_ver = "2000:1.${version}.0_${build}-fcs"
  $rpm_name = "${dist}-${version}u${update}-linux-x64.rpm"
  $source = "${url}/${version}u${update}-b${build}/${rpm_name}"

  # http://stackoverflow.com/questions/10268583/how-to-automate-download-and-installation-of-java-jdk-on-linux
  staging::file { $rpm_name:
    source      => $source,
    curl_option => '-b "oraclelicense=accept-securebackup-cookie"',
    wget_option => '--header "Cookie: oraclelicense=accept-securebackup-cookie"',
  }

  $rpm_file = "/opt/staging/java/${rpm_name}"

  package { $dist:
    ensure   => present,
    provider => rpm,
    source   => $rpm_file,
    require  => Staging::File[$rpm_name],
  }

  exec { 'java_alternatives':
    command     => "alternatives --install /usr/bin/java java ${path}/bin/java 30000",
    path        => $::path,
    refreshonly => true,
    subscribe   => Package[$dist],
  }
}