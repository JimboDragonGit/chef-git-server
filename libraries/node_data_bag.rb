
module ChefGitServer
  module NodeDataBag
    include Chef::DSL
    include Chef::DSL::Recipe

    class UnFoundNodeDataSetting < StandardError; end
    class UnknownNodeDataSetting < StandardError; end
    class TooManyNodeDataSetting < StandardError; end

    # def self.chef_context
    #   @chef_run_context
    # end

    # def self.cookbook
    #   @chef_cookbook
    # end

    # def self.chef_run_context
    #   @chef_run_context.run_context
    # end

    # def self.set_run_context(run_context)
    #   Chef::Log.warn("Set chef_run_context(#{@chef_run_context.nil?}) with #{run_context.class.name} => #{run_context.inspect}")
    #   @chef_run_context ||= run_context
    # end

    # def self.set_cookbook(cookbook_obj)
    #   Chef::Log.warn("Set chef_cookbook(#{@chef_cookbook.nil?}) with #{cookbook_obj.class.name} => #{cookbook_obj}")
    #   @chef_cookbook ||= cookbook_obj
    # end

    def assigned_run_context(new_context)
      @chef_run_context = new_context
    end

    # def run_context
    #   ChefGitServer::NodeDataBag.chef_run_context
    # end

    # def node
    #   run_context.node
    # end

    # def cookbook
    #   ChefGitServer::NodeDataBag.cookbook
    # end

    # def cookbook_name
    #   cookbook.name
    # end

    # def get_users_data_bag
    #   data_bag userdatabag
    # end

    # def get_secretdatabag
    #   data_bag_item secretdatabag, secretdatabagitem
    # end

    # def get_secret
    #   get_secretdatabag[secretdatabagkey]
    # end

    def userdatabag
      Chef::Log.debug("node['chef-git-server'] is #{node['chef-git-server']}")
      Chef::Log.debug("userdatabag is #{node['chef-git-server']['userdatabag']}(#{node['chef-git-server'][__method__.to_s]})")
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

    def node
      @chef_run_context.node
    end

    def run_context
      @chef_run_context.run_context
    end

    def cookbook_name
      @chef_run_context.cookbook_name
    end

    def recipe_name
      @chef_run_context.recipe_name
    end

    private
    def found_chef_settings(setting_name)
      [setting_name, setting_name.to_s].map do |mn|
        Chef::Config[mn] if Chef::Config.to_hash.key?(mn)
      end.reject do |setting|
        setting.nil?
      end.first
    end

    def found_context_settings(setting_name)
      found_settings = if @chef_run_context.respond_to?(:to_hash)
        [setting_name, setting_name.to_s].map do |mn|
          @chef_run_context.to_hash.key?(mn)
        end
      else
        [setting_name, setting_name.to_s].map do |mn|
          @chef_run_context.send(mn) if @chef_run_context.respond_to?(mn)
        end
      end
      found_settings.reject do |setting|
        setting.nil?
      end.first
    end

    def found_node_settings(setting_name)
      selected_node = [self, @chef_run_context].select do |current_node|
        current_node.respond_to?(:node)
      end.first.node
      [setting_name, setting_name.to_s].map do |mn|
        selected_node[mn] if selected_node.to_hash.key?(mn)
      end.reject do |setting|
        setting.nil?
      end.first
    end

    # def method_missing(method_name, *argv, &block)
    #   method_message = "ChefGitServer::NodeDataBag method #{method_name}(with #{argv.count} parameters)"
    #   Chef::Log.debug(method_message)

    #   found_settings = [
    #     found_chef_settings(method_name),
    #     found_context_settings(method_name),
    #     found_node_settings(method_name)
    #   ].reject do |setting|
    #     setting.nil?
    #   end
    #   raise TooManyNodeDataSetting, [method_message, found_settings.count].join("with") if found_settings.count > 3
    #   # raise UnknownNodeDataSetting, [method_message, caller].join("\n")
    #   Chef::Log.debug("#{method_message} returned with (#{found_settings.count})\nValues are #{found_settings.map {|setting| "#{setting.class.name}"}}")
    #   return found_settings.first if found_settings.any?
    #   raise UnfoundNodeDataSetting, [method_message, caller].join("\n")
    # end
  end
end
