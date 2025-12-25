
module Workspace
  class RepoCollection
    include Workspace::NodeDataBag

    attr_reader :repositories

    def initialize
      @repositories = if node['chef-git-server']['repositories'].kind_of? RepoCollection
        node['chef-git-server']['repositories'].repositories
      else
        node['chef-git-server']['repositories'].map do |repo_name|
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
