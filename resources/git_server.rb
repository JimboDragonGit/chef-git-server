# name 'Resource file for chef_workstation_initialize'
# maintainer 'Jimbo Dragon'
# maintainer_email 'jimbo_dragon@hotmail.com'
# license 'MIT'
# description 'Resource file for chef_workstation_initialize'
# version '0.1.0'
# chef_version '>= 16.6.14'
# issues_url 'https://github.com/jimbodragon/chef_workstation_initialize/issues'
# source_url 'https://github.com/jimbodragon/chef_workstation_initialize'

# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/

require 'fileutils'

resource_name :git_server
provides :git_server


property :repositories, Array, default: []
property :user, String, default: "git"
property :group, String, default: "git"
property :home, String, default: "/home/git"
property :shell, String, default: "/usr/bin/git-shell"
property :user_comment, String, default: "User to connect with git"
property :user_data_bag, String, default: "user"
property :username_data_bag, String, default: "username"
property :ssh_keys_data_bag, String, default: "ssh_keys"
property :compile_time, [TrueClass, FalseClass], default: false

actions :install, :update_user
default_action :install

load_current_value do |desired|
end

action :install do
  create_server
  init_repo
end

action :update_user do
  update_ssh_users
end

action_class do

  def create_server
    # Create git user on server
    user node['chef-git-server']['user'] do
      manage_home true
      comment node['chef-git-server']['user_comment']
      home node['chef-git-server']['home']
      shell node['chef-git-server']['shell']
      compile_time node['chef-git-server']['compile_time']
    end

    directory File.join(node['chef-git-server']['home'], ".ssh") do
      user node['chef-git-server']['user']
      group node['chef-git-server']['group']
      mode "700"
      compile_time node['chef-git-server']['compile_time']
    end
  end

  def update_ssh_users
    # Pulls all SSH Keys out of users databag and adds to the git user
    # authorized_keys.  See users cookbook for details"
    begin
      users = data_bag(node['chef-git-server']['user_data_bag'])
      ssh_keys = ''
      users.each do |username|
        user = data_bag_item(node['chef-git-server']['user_data_bag'], username)
        user[node['chef-git-server']['ssh_keys_data_bag']].each do |ssh_key|
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
      compile_time node['chef-git-server']['compile_time']
    end
  end

  def init_repo
    # Setup repositories defined as node attributes
    node['chef-git-server']['repositories'].each do |repository_name|
      execute "git init --bare #{repository_name}.git" do
        user node['chef-git-server']['user']
        group node['chef-git-server']['group']
        cwd node['chef-git-server']['home']
        creates File.join(node['chef-git-server']['home'], "#{repository_name}.git")
        compile_time node['chef-git-server']['compile_time']
      end
    end
  end
end