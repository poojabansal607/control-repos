## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# Disable filebucket by default for all File resources:
#https://docs.puppet.com/pe/2015.3/release_notes.html#filebucket-resource-no-longer-created-by-default
File { backup => false }
filebucket { 'main':
   server => 'del2vmpldevop02.sapient.com',
   path => false,
}

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

node del2vmpldevop03.sapient.com {
  # This is where you can declare classes for all nodes.
  # Example:
  #   class { 'my_class': }

  class { 'mysql::client':}
  
  class { '::mysql::server':
  root_password    => 'strongpassword',
  
  override_options => { 'mysqld' => { 'bind-address' => '10.202.7.250' , 'max_connections' => '1024' } }
}

mysql::db { 'devops_db':
  user     => 'root',
  password => 'strongpassword',
  host     => '10.202.7.250',
  sql      => ['/etc/puppetlabs/puppet/deploy_files/mysql/CreateTable.sql','/etc/puppetlabs/puppet/deploy_files/mysql/InsertData.sql'],
  require  => File['/etc/puppetlabs/puppet/deploy_files/mysql/CreateTable.sql','/etc/puppetlabs/puppet/deploy_files/mysql/InsertData.sql']
}

file { "/etc/puppetlabs/puppet/deploy_files/mysql/CreateTable.sql":
  ensure => present,
  source => "puppet:///deploy_files/mysql/CreateTable.sql",
}

file { "/etc/puppetlabs/puppet/deploy_files/mysql/InsertData.sql":
  ensure => present,
  source => "puppet:///deploy_files/mysql/InsertData.sql",
}

mysql_grant { 'root@10.202.7.250/*.*':
  ensure     => 'present',
  options    => ['GRANT'],
  privileges => ['ALL'],
  table      => '*.*',
  user       => 'root@10.202.7.250',
}

#include oraclejdk8
#oraclejdk8::install{oraclejdk8-local:}
 file { '/etc/puppetlabs/puppet/deploy_files/gs-service':
  ensure => 'directory',
  source => 'puppet:///deploy_files/gs-service',
  recurse => 'true',
 # path => '/etc/puppetlabs/code/modules/deploy_files',
  owner => 'root',
  group => 'root',
  mode => '0755',
  links => 'manage',
  source_permissions => 'ignore',
}
 file { '/etc/puppetlabs/puppet/deploy_files/assessment':
 ensure => 'directory',
  source => 'puppet:///deploy_files/assessment',
  recurse => 'true',
  owner => 'root',
  group => 'root',
  mode => '0755',
  links => 'manage',
  source_permissions => 'ignore',
}
exec { 'run_my_assessment':
   cwd => '/etc/puppetlabs/puppet/deploy_files/assessment',
   command => 'java -jar target/assessment-1.0-SNAPSHOT.jar server src/main/resources/devops-assessment.yml',
   path => '/usr/bin',
   timeout => '0',
}
exec { 'run_my_script':
   cwd => '/etc/puppetlabs/puppet/deploy_files/gs-service',
   command => 'java -jar target/gs-rest-service-cors-0.1.0.jar',
  # logoutput => 'true',
   path => '/usr/bin',
   timeout => '0',
 }
  }