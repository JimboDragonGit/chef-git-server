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

resource_name :chef_git_server
provides :chef_git_server

property :repositories, Array, default: []
property :user, String, default: 'git'
property :group, String, default: 'git'
property :home, String, default: '/home/git'
property :shell, String, default: '/home/git/git-shell-commands'
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

action :update_users do
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

    file ::File.join(new_resource.home, 'git-shell-commands') do
      content <<~EOB
        #!/bin/bash
        mkdir -p ~/logs
        echo "$@" > ~/logs/access.log

        log() {
          echo "$1" >> ~/logs/access.log
        }

        is_it_for_git=$1
        what_is_the_git_command=$2
        git_command=$(echo "$2" | awk '{print $1}')
        path_to_access=$(echo "$2" | awk '{print $2}' | cut -d "'" -f 2)

        log "is_it_for_git = $is_it_for_git"
        log "what_is_the_git_command = $what_is_the_git_command"
        log "git_command = $git_command"
        log "path_to_access = $path_to_access"

        if [ "$is_it_for_git" == "-c" ]
        then
          log "It is for a command"
          if [ "$git_command" == "git-upload-pack" ]
          then
            log "It is for an upload"
            if [ -d $path_to_access ]
            then
              log "$path_to_access is valid"
              valid_git="valid"
            fi
          fi
        fi

        if [ "$valid_git" == "valid" ]
        then
          log "Passing handler to git-shell"
          /usr/bin/git-shell $@
        else
          echo Welcome to JimboDragon
          echo SSH Login Not Authorized
        fi

      EOB
      user new_resource.user
      group new_resource.group
      mode '555'
    end

    directory ::File.join(new_resource.home, '.ssh') do
      user new_resource.user
      group new_resource.group
      mode '700'
    end

    directory ::File.join(new_resource.home, 'logs') do
      user new_resource.user
      group new_resource.group
      mode '755'
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

      logger.debug("#{login} :: userdatabagkey = #{new_resource.userdatabagkey}")
      userinfo[new_resource.userdatabagkey].each do |ssh_key|
        logger.debug("ssh_key[#{login}][#{new_resource.userdatabagkey}] = #{ssh_key}")
        logger.debug("ssh_key[#{login}][ssh_comment] = #{ssh_key['ssh_comment']}")
        logger.debug("ssh_key[#{login}][ssh_key_type] = #{ssh_key['ssh_key_type']}")

        ssh_authorize_key login do
          key ssh_key['key']
          keytype ssh_key['ssh_key_type']
          comment ssh_key['ssh_comment']
          user new_resource.user
          group new_resource.group
        end
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
