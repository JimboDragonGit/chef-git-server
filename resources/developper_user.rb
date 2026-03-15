# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/

ChefGitServer::NodeDataBag.set_run_context(self)

resource_name :developper_user
provides :developper_user

property :developpername, String, name_property: true
property :developper, ChefGitServer::WorkUser, default: ChefGitServer::WorkUser.new(ENV["USER"])
property :file_from_cookbook, String, default: 'chef-git-server'

actions :set_repository, :generate_github_access, :generate_aws_access

unified_mode true

default_action :set_repository

load_current_value do |default_values|
  # current_value_does_not_exist! if
end

action :set_repository do
  converge_if_changed do
    repositories = ChefGitServer::RepoCollection.new

    local_repositories developper.login do
      developper developper
      repo_collection repositories
      action [ :fetch, :first_commit, :sync ]
    end
  end
end

action :generate_github_access do
  converge_if_changed do
    create_directory '.ssh'

    file from_home(".ssh/id_rsa") do
      content developper.ssh_private_key
      owner developper.login
      group developper.group
      mode "600"
      action :create_if_missing
    end

    file from_home(".ssh/id_rsa.pub") do
      content developper.ssh_public_key
      owner developper.login
      group developper.group
      mode "600"
      action :create_if_missing
    end

    file from_home(".ssh/config") do
      content <<~EOB
      Host github.com
        HostName github.com
        User git
      EOB
      owner developper.login
      group developper.group
      mode "600"
      action :create_if_missing
    end

    template from_home(".gitconfig") do
      source 'gitconfig.erb'
      owner developper.login
      group developper.group
      mode "600"
      variables(
        developper: developper,
        git_localhost_redirect: node['workspace']['git_localhost_redirect']
      )
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
        owner developper.login
        group developper.group
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
      owner developper.login
      group developper.group
      mode "600"
      action :create_if_missing
    end

    cookbook_file from_home(".aws/credentials") do
      source "profile.d/root/aws/credentials"
      owner developper.login
      group developper.group
      mode "600"
      action :create_if_missing
    end
  end
end

action :generate_aauthorized_keys do
  converge_if_changed do
    developper.authorized_ssh_users.each do |ssh_user, ssh_key|
      logger.debug("authorized_ssh_users[#{ssh_user}][#{developper.login}] = #{ssh_key}")
      logger.debug("authorized_ssh_users[#{ssh_user}][ssh_comment] = #{ssh_key['ssh_comment']}")
      logger.debug("authorized_ssh_users[#{ssh_user}][ssh_key_type] = #{ssh_key['ssh_key_type']}")

      ssh_authorize_key ssh_user do
        key ssh_key['key']
        keytype ssh_key['ssh_key_type']
        comment ssh_key['ssh_comment']
        user developper.login
        group developper.group
      end
    end
  end
end

action_class do
  def developper
    new_resource.developper
  end

  def from_home(to_path)
    ::File.join(developper.home, to_path)
  end

  def create_directory(folder_from_home)
    directory from_home(folder_from_home) do
      owner developper.login
      group developper.group
      mode "755"
      action :create
    end
  end
end
