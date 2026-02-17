# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/

ChefGitServer::NodeDataBag.set_run_context(self)

resource_name :developper_user
provides :developper_user

property :developpername, String, name_property: true
property :developper, ChefGitServer::WorkUser, default: ChefGitServer::WorkUser.new(ENV["USER"])
property :file_from_cookbook, String, default: 'chef-git-server'

actions :sync, :delete_features

unified_mode true

default_action :sync

load_current_value do |default_values|
  # current_value_does_not_exist! if
end

action :set_repository do
  converge_if_changed do
    repositories = ChefGitServer::RepoCollection.new

    local_repositories new_resource.developper.login do
      developper new_resource.developper
      repo_collection repositories
      action [ :fetch, :first_commit, :sync ]
    end
  end
end

action :generate_github_access do
  converge_if_changed do
    create_directory '.ssh'

    file from_home(".ssh/id_rsa") do
      content new_resource.developper.ssh_private_key
      owner new_resource.developper.login
      group new_resource.developper.group
      mode "600"
      action :create_if_missing
    end

    file from_home(".ssh/id_rsa.pub") do
      content new_resource.developper.ssh_public_key
      owner new_resource.developper.login
      group new_resource.developper.group
      mode "600"
      action :create_if_missing
    end

    file from_home(".ssh/config") do
      content <<~EOB
      Host github.com
        HostName github.com
        User git
      EOB
      owner new_resource.developper.login
      group new_resource.developper.group
      mode "600"
      action :create_if_missing
    end

    file from_home(".gitconfig") do
      content <<~EOB
      [init]
        defaultBranch = master
      [core]
        editor = code --wait
        autocrlf = false
      [log]
        editor = code --wait
        autocrlf = false
      [author]
        name = #{new_resource.developper.firstname} #{new_resource.developper.lastname}
        email = #{new_resource.developper.email}
      [committer]
        name = #{new_resource.developper.firstname} #{new_resource.developper.lastname}
        email = #{new_resource.developper.email}
      [user]
        name = #{new_resource.developper.firstname} #{new_resource.developper.lastname}
        email = #{new_resource.developper.email}
      [pull]
        rebase = false
      [push]
        autoSetupRemote = true
      [safe]
        directory = #{new_resource.developper.env_folder}
      [worktree]
        guessRemote = true
      [protocol "codecommit"]
        allow = always
      [url "ssh://git@github.com"]
        insteadOf = https://github.com

      EOB
      owner new_resource.developper.login
      group new_resource.developper.group
      mode "600"
      action :create_if_missing
    end

    checkout_host = %w[
      github.com
    ]
    checkout_host << 'localhost' unless docker?

    node['workspace']['additionnal_ssh_known_host'].each do |additionnal_host|
      checkout_host << additionnal_host
    end

    checkout_host.each do |host|
      ssh_known_hosts_entry host do
        owner new_resource.developper.login
        group new_resource.developper.group
        file_location from_home(".ssh/known_host")
        compile_time true
        retries 5
        retry_delay 3
        action :create
      end
    end
  end
end

action :generate_aws_access do
  converge_if_changed do
    create_directory '.aws'

    cookbook_file from_home(".aws/config") do
      source "profile.d/root/aws/config"
      owner new_resource.developper.login
      group new_resource.developper.group
      mode "600"
      action :create_if_missing
    end

    cookbook_file from_home(".aws/credentials") do
      source "profile.d/root/aws/credentials"
      owner new_resource.developper.login
      group new_resource.developper.group
      mode "600"
      action :create_if_missing
    end
  end
end

action_class do
  def from_home(to_path)
    ::File.join(new_resource.developper.home, to_path)
  end

  def create_directory(folder_from_home)
    directory from_home(folder_from_home) do
      owner new_resource.developper.login
      group new_resource.developper.group
      mode "755"
      action :create
    end
  end
end
