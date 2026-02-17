
module ChefGitServer
  class RepoCollection
    include ChefGitServer::NodeDataBag

    attr_reader :repositories

    def initialize
      # Chef::Log.warn("node workspace config is: #{node['workspace']['config']}")
      Chef::Log.debug("node workspace config is: #{node['chef-git-server']['repositories']}")
      @repositories = if node['chef-git-server']['repositories'].kind_of? RepoCollection
        node['chef-git-server']['repositories'].repositories
      else
        node['chef-git-server']['repositories'].map do |repo_name|
          Chef::Log.debug("Fetching repo information of #{repo_name}")
          all_config_remote = node['workspace']['config'][repo_name]['remotes'].merge(
            {
              origin: node['workspace']['config'][repo_name]['origin']
            }
          )
          Repository.new(repo_name, all_config_remote)
        end
      end
    end
  end
end
