
# Installation/System attributes

# Array of repository names. Do not include '.git' extensions.
default['chef-git-server']['repositories'] = %w(example_a example_b)
default['chef-git-server']['user'] = 'git'
default['chef-git-server']['group'] = 'git'
default['chef-git-server']['home'] = '/home/git'
default['chef-git-server']['shell'] = '/usr/bin/git-shell'
default['chef-git-server']['user_comment'] = 'User to connect with git'
default['chef-git-server']['userdatabagkey'] = 'public_keys'
default['chef-git-server']['compile_time'] = false
default['chef-git-server']['userdatabag'] = 'users'
default['chef-git-server']['secretdatabag'] = 'secret_databag_bag'
default['chef-git-server']['secretdatabagitem'] = 'secret_item'
default['chef-git-server']['secretdatabagkey'] = 'secret'
