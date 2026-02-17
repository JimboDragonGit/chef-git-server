#
# Chef Infra Documentation
# https://docs.chef.io/libraries/
#

#
# This module name was auto-generated from the cookbook name. This name is a
# single word that starts with a capital letter and then continues to use
# camel-casing throughout the remainder of the name.
#

require_relative 'node_data_bag'

module ChefGitServer
  module GitRepo
    include ChefGitServer::NodeDataBag

    class NoMasterBranchAtRemote < RuntimeError; end

    def clean_repo_message
      <<~EOS
        Your branch is up to date with 'origin/master'.
        
        nothing to commit, working tree clean
      EOS
    end

    def remote_repo_verified?(repo_name, repo_url)
      remote_ls = Mixlib::ShellOut.new("git ls-remote '#{repo_url}' 'master*'")
      if remote_ls.run_command.error? && remote_ls.stdout.empty? && remote_ls.stderr.empty?
        false
      elsif remote_ls.stdout.empty? && remote_ls.stderr.empty?
        false
      elsif remote_ls.stdout.include?('refs') && remote_ls.stdout.include?('master')
        true
      else
        raise NoMasterBranchAtRemote, "Error while verifying remote repository for #{repo_name}\n#{repo_url}\n::#{remote_ls.stdout}\n#{remote_ls.stderr}"
      end
    end

    def has_something_to_commit?
      status = Mixlib::ShellOut.new("git status").run_command
      Chef::Log.warn("status is #{status.stdout}")
      if status.error?
        Chef::Log.warn("status has error with\nSTDOUT: #{status.stdout}\nSTDERR: #{status.stderr}")
        false
      elsif status.stdout.include?(clean_repo_message)
        Chef::Log.warn("status is clean with #{status.stdout}")
        false
      else
        Chef::Log.warn("New commit require as per #{status.stdout}")
        true
      end
    end
  end
end
