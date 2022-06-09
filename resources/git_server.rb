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

  include ChefGitServer::SshKeysHelpers

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

  def update_ssh_users
    # Pulls all SSH Keys out of users databag and adds to the git user
    # authorized_keys.  See users cookbook for details"

    file ::File.join(new_resource.home, ::File.join('.ssh', 'authorized_keys')) do
      helpers ChefGitServer::SshKeysHelpers
      owner new_resource.user
      group new_resource.group
      mode "600"
      content sshkeys(new_resource)
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
