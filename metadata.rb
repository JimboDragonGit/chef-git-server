name             'chef-git-server'
maintainer       'Brian Hartsock'
maintainer_email 'brian.hartsock@gmail.com'
license          'All rights reserved'
description      'Sets up a simple SSH based git server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.1.3'
chef_version '>= 16.6.14'

depends 'ssh_authorized_keys', '~> 1.0'

gem 'unix-crypt'
gem 'ruby-shadow'
gem 'chef-vault'
gem 'veil'
