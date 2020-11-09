#
# Cookbook Name:: git-server
# Recipe:: default
#
#

# Create git user on server
user node['git-server']['user'] do
  supports :manage_home => true
  comment node['git-server']['user_comment']
  home node['git-server']['home']
  shell node['git-server']['shell']
end

directory File.join(node['git-server']['home'], ".ssh") do
  user node['git-server']['user']
  group node['git-server']['group']
  mode "700"
end

# Pulls all SSH Keys out of users databag and adds to the git user
# authorized_keys.  See users cookbook for details"
users = data_bag(node['git-server']['user_data_bag'])
ssh_keys = ''
users.each do |username|
  user = data_bag_item(node['git-server']['user_data_bag'], node['git-server']['username_data_bag'])
  Array(user[node['git-server']['ssh_keys_data_bag']]).each do |ssh_key|
    ssh_keys << ssh_key + "\n"
  end
end

file File.join(node['git-server']['home'], File.join('.ssh', 'authorized_keys')) do
  owner node['git-server']['user']
  group node['git-server']['group']
  mode "600"
  content ssh_keys
end

# Setup repositories defined as node attributes
node['git-server']['repositories'].each do |repository_name|
  execute "git init --bare #{repository_name}.git" do
    user node['git-server']['user']
    group node['git-server']['group']
    cwd node['git-server']['home']
    creates File.join(node['git-server']['home'], "#{repository_name}.git")
  end
end
