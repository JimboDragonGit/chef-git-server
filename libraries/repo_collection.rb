
module ChefGitServer
  class RepoCollection
    include ChefGitServer::NodeDataBag
    include ChefGitServer::ChefContextHelpers

    attr_reader :repositories

    def initialize(new_context)
      @chef_run_context = new_context
      # Chef::Log.warn("node workspace config is: #{node['workspace']['config']}")
      Chef::Log.debug("node workspace config is: #{node['chef-git-server']['repositories']}")
      @repositories = if node['chef-git-server']['repositories'].kind_of? RepoCollection
        node['chef-git-server']['repositories'].repositories
      else
        node['chef-git-server']['repositories'].map do |repo_name|
          Chef::Log.debug("Fetching repo information of #{repo_name}")
          assign_origin = if docker?
            node['workspace']['config'][repo_name]['origin_for_docker']
          else
            node['workspace']['config'][repo_name]['origin']
          end
          all_config_remote = node['workspace']['config'][repo_name]['remotes'].merge(
            {
              origin: assign_origin
            }
          )
          Repository.new(repo_name, all_config_remote, node['workspace']['config'][repo_name]['origin_branch'])
        end
      end
    end
  end
end
