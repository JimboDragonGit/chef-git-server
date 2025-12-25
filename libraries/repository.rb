
module Workspace
  class Repository
    include Workspace::GitRepo

    class WithDevelopper
      include NodeDataBag

      attr_reader :repository, :developper

      def initialize(login, repo)
        @repository = repo
        @developper = login
      end

      def default_clone_folder
        ::File.join(developper.env_folder, repository.name)
      end

      def clone_into(clone_into_folder = nil)
        clone_into_folder.nil? ? default_clone_folder : clone_into_folder
      end

      def push_to_origin(clone_into_folder = nil)
        git_push_cmd = "git push origin master"
        if block_given?
          yield(
            developper.login,
            developper.group,
            git_push_cmd,
            clone_into(clone_into_folder),
            developper.user_env,
            nil
          )
        else
          developper.run_command!(git_push_cmd, clone_into(clone_into_folder))
        end
      end

      def push_all_remotes(clone_into_folder = nil)
        repository.remotes.each do |remote_name, remote_url|
          git_push_cmd = "git push #{remote_name} master"
          if block_given?
            yield(
              developper.login,
              developper.group,
              git_push_cmd,
              clone_into(clone_into_folder),
              developper.user_env,
              [0, 1]
            )
          else
            developper.run_command!(git_push_cmd, clone_into(clone_into_folder))
          end
        end
      end

      def pull_all_remotes(clone_into_folder = nil)
        repository.remotes.each do |remote_name, remote_url|
          git_pull_cmd = "git pull #{remote_name} master"
          if block_given?
            yield(
              developper.login,
              developper.group,
              git_pull_cmd,
              clone_into(clone_into_folder),
              developper.user_env,
              [0, 1]
            )
          else
            developper.run_command!(git_pull_cmd, clone_into(clone_into_folder))
          end
        end
      end

      def cloned?(clone_into_folder = nil)
        Dir.exist?(clone_into(clone_into_folder))
      end

      def not_commited_yet?(clone_into_folder = nil)
      end

      def clone_from_first_valid_remote(clone_into_folder = nil)
        clone_folder = clone_into(clone_into_folder)
        unless Dir.exist?(clone_folder)
          parent_folder = File.dirname(clone_folder)
          Chef::Log.warn("Will Clone #{repository.name} to #{parent_folder}")
          repository.remotes.each do |remote_name, remote_url|
            begin
              status = repository.remote_verified?(remote_name) && ! cloned?

              if block_given? && status == true
                yield(
                  developper.login,
                  developper.group,
                  "git clone #{remote_url} #{clone_folder}",
                  [
                    "git remote add #{remote_name} #{remote_url}",
                    "git remote set-url origin #{repository.origin_url}",
                    "git push origin master"
                  ],
                  clone_folder,
                  developper.user_env,
                  [0, 1]
                )
              else
                developper.run_command!("git clone #{remote_url} #{clone_folder}", parent_folder) if status == true
              end
            rescue Workspace::GitRepo::NoMasterBranchAtRemote => e
              next
            end
          end
        end
      end

      def generate_first_commit
        Chef::Log.debug("repository.name= #{repository.name}")
        Chef::Log.debug("developper.sandbox_folder = #{developper.sandbox_folder}")

        git_clone_cmd = "git clone #{repository.origin_url}"
        git_add_cmd = "git add ."
        git_commit_cmd = "git commit -m 'First commit for #{repository.name}'"
        git_push_cmd = "git push"

        if block_given?
          yield(
            developper.login,
            developper.group,
            [git_clone_cmd, git_add_cmd, git_commit_cmd, git_push_cmd],
            developper.sandbox_folder,
            developper.user_env,
            nil
          )
        else
          clone_to_sandbox = ::File.join(developper.sandbox_folder, repository.name)
          Chef::Log.warn("Playing in #{clone_to_sandbox}")

          FileUtils.rm_rf(clone_to_sandbox)
          FileUtils.mkdir_p(developper.sandbox_folder)

          Mixlib::ShellOut.new("#{git_clone_cmd} #{clone_to_sandbox}", cwd: developper.sandbox_folder, environment: developper.user_env)

          Dir.chdir(clone_to_sandbox) do
            readme = <<~EOL
              First Commit
            EOL
            ::File.write(::File.join(clone_to_sandbox, 'README.md'), readme)
            developper.run_command!(git_add_cmd, clone_to_sandbox)
            developper.run_command!(git_commit_cmd, clone_to_sandbox)
            developper.run_command!(git_push_cmd, clone_to_sandbox)
          end

          FileUtils.rm_rf(clone_to_sandbox)
        end
      end
    end

    attr_reader :name, :remotes
    def initialize(repo_name, remote_list)
      @name = repo_name
      @remotes = remote_list
    end

    def with_developper(developper)
      WithDevelopper.new(developper, self)
    end

    def origin_url
      remotes[:origin]
    end

    def no_commit_yet?
      ! has_at_least_1_remote_valid?
    end

    def origin_verified?
      begin
        status = remote_repo_verified?(name, origin_url)
      rescue Workspace::GitRepo::NoMasterBranchAtRemote => e
        status = false
      end
      status
    end

    def remote_verified?(remote_name)
      begin
        status = remote_repo_verified?(name, remotes[remote_name.to_sym])
      rescue Workspace::GitRepo::NoMasterBranchAtRemote => e
        status = false
      end
      status
    end

    def has_at_least_1_remote_valid?
      remotes.each do |remote_name, remote_url|
        begin
          status = remote_repo_verified?(name, remote_url)
        rescue Workspace::GitRepo::NoMasterBranchAtRemote => e
          status = false
        end
        return true if status == true
      end

      false
    end

    def all_remotes_verified?
      remotes.each do |remote_name, remote_url|
        begin
          status = remote_repo_verified?(name, remote_url)
        rescue Workspace::GitRepo::NoMasterBranchAtRemote => e
          status = false
        end
        return false if status == false
      end

      true
    end
  end
end
