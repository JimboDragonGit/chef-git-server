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
  end
end
