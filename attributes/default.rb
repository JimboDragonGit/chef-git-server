
# Installation/System attributes

# Array of repository names. Do not include ".git" extensions.
default['chef-git-server']['repositories'] = []
default['chef-git-server']['user'] = "git"
default['chef-git-server']['group'] = "git"
default['chef-git-server']['home'] = "/home/git"
default['chef-git-server']['shell'] = "/usr/bin/git-shell"
default['chef-git-server']['user_comment'] = "ssh_keys"
default['chef-git-server']['user_data_bag'] = "user"
default['chef-git-server']['username_data_bag'] = "username"
default['chef-git-server']['ssh_keys_data_bag'] = "ssh_keys"
