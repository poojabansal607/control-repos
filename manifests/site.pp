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
include '::mysql::server'
mysql::db { 'devops_db':
  user => 'root',
  password => 'root',
  host => 'del2vmpldevop03.sapient.com',
  grant    => ['SELECT', 'UPDATE'],
}
mysql_user { 'root@127.0.0.1':
 ensure => 'present',
 max_connections_per_hour => '100',
 max_queries_per_hour => '200',
 max_updates_per_hour => '200',
 max_user_connections => '80',
 }
mysql_grant { 'root@localhost/*.*':
ensure => 'present',
options => ['GRANT'],
privileges => ['ALL'],
table => '*.*',
user => 'root',
}
}








