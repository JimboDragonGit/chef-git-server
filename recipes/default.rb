#
# Cookbook Name:: chef-git-server
# Recipe:: default
#
#

# Create git user on server
user node['chef-git-server']['user'] do
  manage_home true
  comment node['chef-git-server']['user_comment']
  home node['chef-git-server']['home']
  shell node['chef-git-server']['shell']
end

directory File.join(node['chef-git-server']['home'], ".ssh") do
  user node['chef-git-server']['user']
  group node['chef-git-server']['group']
  mode "700"
end

# Pulls all SSH Keys out of users databag and adds to the git user
# authorized_keys.  See users cookbook for details"
begin
  users = data_bag(node['chef-git-server']['user_data_bag'])
  ssh_keys = ''
  users.each do |username|
    user = data_bag_item(node['chef-git-server']['user_data_bag'], node['chef-git-server']['username_data_bag'])
    Array(user[node['chef-git-server']['ssh_keys_data_bag']]).each do |ssh_key|
      ssh_keys << ssh_key + "\n"
    end
  end
rescue
  ssh_keys = ''
end

file File.join(node['chef-git-server']['home'], File.join('.ssh', 'authorized_keys')) do
  owner node['chef-git-server']['user']
  group node['chef-git-server']['group']
  mode "600"
  content ssh_keys
end

# Setup repositories defined as node attributes
node['chef-git-server']['repositories'].each do |repository_name|
  execute "git init --bare #{repository_name}.git" do
    user node['chef-git-server']['user']
    group node['chef-git-server']['group']
    cwd node['chef-git-server']['home']
    creates File.join(node['chef-git-server']['home'], "#{repository_name}.git")
  end
end
