
# Installation/System attributes

# Array of repository names. Do not include ".git" extensions.
default['git-server']['repositories'] = []
default['git-server']['user'] = "git"
default['git-server']['group'] = "git"
default['git-server']['home'] = "/home/git"
default['git-server']['shell'] = "/usr/bin/git-shell"
default['git-server']['user_comment'] = "ssh_keys"
default['git-server']['user_data_bag'] = "user"
default['git-server']['username_data_bag'] = "username"
default['git-server']['ssh_keys_data_bag'] = "ssh_keys"
