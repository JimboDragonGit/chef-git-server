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
property :user, String, default: "git"
property :group, String, default: "git"
property :home, String, default: "/home/git"
property :shell, String, default: "/usr/bin/git-shell"
property :user_comment, String, default: "User to connect with git"
property :user_data_bag, String, default: "git_ssh_keys"
property :ssh_keyname_data_bag, String, default: "public_keys"
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

  require 'fileutils'

  attr_accessor :sshkeys

  def create_server
    # Create git user on server
    user new_resource.user do
      manage_home true
      comment new_resource.user_comment
      home new_resource.home
      shell new_resource.shell
    end

    directory ::File.join(new_resource.home, ".ssh") do
      user new_resource.user
      group new_resource.group
      mode "700"
    end
  end

  def sshkeys
    begin
      Chef::Log.warn("Fetch git ssh users")
      @ssh_keys = ''
      users = data_bag(new_resource.user_data_bag)
      Chef::Log.warn("Fetch git ssh users #{users}")
      users.each do |username|
        Chef::Log.warn("Fetch git ssh keys for user #{username}")
        user = data_bag_item(new_resource.user_data_bag, username)
        Chef::Log.warn("Fetch git ssh keys for user #{username} = Hash #{user.to_hash}")
        # Chef::Log.warn("Fetch git ssh keys for user #{username} = key #{user.key}")
        Chef::Log.warn("Fetch git ssh keys for user #{username} = keys #{user.keys}")
        Chef::Log.warn("Fetch git ssh keys for user #{username} = values #{user.values}")
        user[new_resource.ssh_keyname_data_bag].each do |ssh_key|
          Chef::Log.warn("Adding git ssh keys for user #{username} = #{user} with value #{ssh_key}")
          @ssh_keys << ssh_key + "\n"
        end
      end
    rescue Exception => e
      @ssh_keys = "Error running sshkeys with exception #{e.message}}"
    end
    @ssh_keys
  end

  def update_ssh_users
    # Pulls all SSH Keys out of users databag and adds to the git user
    # authorized_keys.  See users cookbook for details"

    file ::File.join(new_resource.home, ::File.join('.ssh', 'authorized_keys')) do
      owner new_resource.user
      group new_resource.group
      mode "600"
      content ssh_keys
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
