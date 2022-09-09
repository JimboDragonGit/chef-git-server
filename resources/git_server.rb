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

resource_name :git_server
provides :git_server

property :repositories, Array, default: []
property :user, String, default: 'git'
property :group, String, default: 'git'
property :home, String, default: '/home/git'
property :shell, String, default: '/usr/bin/git-shell'
property :user_comment, String, default: 'User to connect with git'
property :compile_time, [true, false], default: false
property :userdatabag, String, default: 'users'
property :userdatabagkey, String, default: 'public_key'
property :secretdatabag, String, default: 'secret_databag_bag'
property :secretdatabagitem, String, default: 'secret_item'
property :secretdatabagkey, String, default: 'secret'

default_action :install
unified_mode true

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
  require 'fileutils'

  def create_server
    # Create git user on server
    user new_resource.user do
      manage_home true
      comment new_resource.user_comment
      home new_resource.home
      shell new_resource.shell
    end

    directory ::File.join(new_resource.home, '.ssh') do
      user new_resource.user
      group new_resource.group
      mode '700'
    end
  end

  def update_ssh_users
    # Pulls all SSH Keys out of users databag and adds to the git user
    # authorized_keys.  See users cookbook for details'

    users = data_bag(new_resource.userdatabag)
    users.each do |login|
      case ChefVault::Item.data_bag_item_type(new_resource.userdatabag, login)
      when :normal
        userinfo = data_bag_item(new_resource.userdatabag, login)
      when :encrypted
        userinfo = data_bag_item(new_resource.userdatabag, login, data_bag_item(new_resource.secretdatabag, new_resource.secretdatabagitem)[new_resource.secretdatabagkey])
      when :vault
        userinfo = ChefVault::Item.load(new_resource.userdatabag, login)
      end

      ssh_authorized_key login do
        key userinfo[new_resource.userdatabagkey]['key']
        keytype userinfo[new_resource.userdatabagkey]['keytype']
        comment userinfo[new_resource.userdatabagkey]['comment']
        user new_resource.user
        group new_resource.group
      end
    end
  end

  def init_repo
    # Setup repositories defined as node attributes
    new_resource.repositories.each do |repository_name|
      execute "git init --bare #{repository_name}.git" do
        user new_resource.user
        group new_resource.group
        cwd new_resource.home
        creates ::File.join(new_resource.home, "#{repository_name}.git")
      end
    end
  end
end
