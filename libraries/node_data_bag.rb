
module Workspace
  module NodeDataBag
    include Chef::DSL
    include Chef::DSL::Recipe

    def self.chef_context
      @chef_run_context
    end

    def self.cookbook
      @chef_cookbook
    end

    def self.chef_run_context
      @chef_run_context.run_context
    end

    def self.set_run_context(run_context)
      @chef_run_context ||= run_context
    end

    def self.set_cookbook(cookbook_obj)
      @chef_cookbook ||= cookbook_obj
    end

    def run_context
      Workspace::NodeDataBag.chef_run_context
    end

    def node
      run_context.node
    end

    def cookbook
      Workspace::NodeDataBag.cookbook
    end

    def get_users_data_bag
      data_bag userdatabag
    end

    def get_secretdatabag
      data_bag_item secretdatabag, secretdatabagitem
    end

    def get_secret
      get_secretdatabag[secretdatabagkey]
    end

    def userdatabag
      node['chef-git-server'][__method__.to_s]
    end

    def secretdatabag
      node['chef-git-server'][__method__.to_s]
    end

    def secretdatabagitem
      node['chef-git-server'][__method__.to_s]
    end

    def secretdatabagkey
      node['chef-git-server'][__method__.to_s]
    end
  end
end
