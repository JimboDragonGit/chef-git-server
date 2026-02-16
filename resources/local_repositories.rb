# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/

ChefGitServer::NodeDataBag.set_run_context(self)

resource_name :local_repositories
provides :local_repositories

property :developpername, String, name_property: true
property :developper, ChefGitServer::WorkUser, default: ChefGitServer::WorkUser.new(ENV['USER'])
property :repo_collection, ChefGitServer::RepoCollection, default: ChefGitServer::RepoCollection.new

actions :sync, :delete_features

unified_mode true

default_action :sync

load_current_value do
end

action :fetch do
  new_resource.repo_collection.repositories.each do |repository|
    repository_info = repository.with_developper new_resource.developper
    ruby_block "Fetching master branch for #{repository.name} at all remotes" do
      block do
        repository_info.pull_all_remotes do |login, login_group, user_cmd, working_dir, user_env, cmd_returns|
          execute_user_command(login, login_group, user_cmd, working_dir, user_env, cmd_returns)
        end
      end

      only_if do
        repository.origin_verified? && repository_info.cloned?
      end
    end
  end
end

action :first_commit do
  new_resource.repo_collection.repositories.each do |repository|
    repository_info = repository.with_developper new_resource.developper
    ruby_block "Initialize master branch for #{repository.name}" do
      block do
        if repository.no_commit_yet?
          repository_info.generate_first_commit do |login, login_group, user_cmd, working_dir, user_env, cmd_returns|
            clone_to_sandbox = ::File.join(working_dir, repository.name)

            delete_folder clone_to_sandbox

            directory working_dir do
              recursive true
              user login
              group login_group
              mode '755'
            end

            execute_user_command(login, login_group, "#{user_cmd[0]} #{clone_to_sandbox}", working_dir, user_env, cmd_returns)

            file ::File.join(clone_to_sandbox, 'README.md') do
              content <<~EOL
                First Commit
              EOL
              user login
              group login_group
              mode '644'
            end

            execute_user_command(login, login_group, user_cmd[1], clone_to_sandbox, user_env, cmd_returns)
            execute_user_command(login, login_group, user_cmd[2], clone_to_sandbox, user_env, cmd_returns)
            execute_user_command(login, login_group, user_cmd[3], clone_to_sandbox, user_env, cmd_returns)

            delete_folder clone_to_sandbox
          end
        end
      end

      not_if do
        repository.origin_verified? || repository.has_at_least_1_remote_valid? 
      end
    end

    ruby_block "Clone from #{repository.name}" do
      block do
        repository_info.clone_from_first_valid_remote do |login, login_group, clone_command, user_cmds, working_dir, user_env, cmd_returns|
          execute_user_command(login, login_group, clone_command, ::File.dirname(working_dir), user_env, cmd_returns)
          user_cmds.each do |command_to_execute|
            execute_user_command(login, login_group, command_to_execute, working_dir, user_env, cmd_returns)
          end
        end
      end

      only_if do
        repository.has_at_least_1_remote_valid? && ! repository_info.cloned?
      end
    end
  end
end

action :sync do
  directory new_resource.developper.env_folder do
    user new_resource.developper.login
    group new_resource.developper.group
    mode '0755'
    action :create
  end

  new_resource.repo_collection.repositories.each do |repository|
    repository_info = repository.with_developper new_resource.developper
    ruby_block "Initial Syncing from #{repository.name}" do
      block do
        repository_info.push_to_origin do |login, login_group, user_cmd, working_dir, user_env, cmd_returns|
          execute_user_command(login, login_group, user_cmd, working_dir, user_env, cmd_returns)
        end
      end

      only_if do
        repository_info.cloned? && !repository.origin_verified?
      end
    end

    git repository_info.clone_into do
      user repository_info.developper.login
      group repository_info.developper.group
      revision 'master'
      environment repository_info.developper.user_env
      repository repository.origin_url
      additional_remotes repository.remotes
      action :sync

      only_if do
        repository.origin_verified?
      end
    end
  end
end

action_class do
  def execute_user_command(login, login_group, user_cmd, working_dir, user_env, cmd_returns)
    execute user_cmd do
      cwd working_dir
      environment user_env
      user login
      group login_group
      action :run
      returns cmd_returns if cmd_returns
    end
  end

  def delete_folder(folder_to_delete)
    directory folder_to_delete do
      recursive true
      action :delete
    end
  end
end
