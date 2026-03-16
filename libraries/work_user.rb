
module ChefGitServer
  class WorkUser
    include ChefGitServer::NodeDataBag
    include ChefGitServer::ChefContextHelpers

    class UninitializeLogin < RuntimeError; end
    class UnknownWorkUserSetting < RuntimeError; end

    attr_reader :login, :chef_node

    def initialize(username, new_context)
      @chef_run_context = new_context
      @login = username
    end

    def sandbox_folder
      private_info.key?(__method__) ? private_info[__method__] : Dir.mktmpdir
    end

    def user_env
      private_info['env']
    end

    def home
      user_env['HOME']
    end

    def login_group
      private_info['group']
    end

    def ssh_private_key
      private_info[__method__]
    end

    def ssh_public_key
      private_info[__method__]
    end

    def firstname
      private_info[__method__]
    end

    def lastname
      private_info[__method__]
    end

    def email
      private_info[__method__]
    end

    def env_folder
      private_info[__method__]
    end

    def validate_login!
      raise UninitializeLogin, "Need a login for WorkUser" if login.nil?
    end

    def run_command(command, working_dir)
      Chef::Log.warn("Executing the command '#{command}'")
      Mixlib::ShellOut.new(command, cwd: working_dir, environment: user_env).run_command
    end

    def run_command!(command, working_dir)
      Chef::Log.warn("Hoping that the command '#{command}' does not failed at #{working_dir}")
      command_to_execute = Mixlib::ShellOut.new(command, cwd: working_dir, environment: user_env)
      command_to_execute.run_command.error!
      command_to_execute
    end

    protected
    def retrieve_setting(setting_name)
      private_info[setting_name]
    end

    private
    def private_info
      # Chef::Log.warn("login = '#{login}'")
      # Chef::Log.warn("userdatabag = '#{userdatabag}'")
      validate_login!
      case ::ChefVault::Item.data_bag_item_type(userdatabag, login)
      when :normal
        data_bag_item(userdatabag, login)
      when :encrypted
        data_bag_item(userdatabag, login, get_secret).to_h
      when :vault
        ::ChefVault::Item.load(userdatabag, login).to_h
      end
    end

    # def method_missing(method_name, *argv, &block)
    #   method_message = "ChefGitServer::WorkUser method #{method_name}(with #{argv.count} parameters)"
    #   Chef::Log.debug(method_message)
    #   found_settings = [method_name, method_name.to_s].select do |mn|
    #     private_info.key?(mn)
    #   end
    #   return found_settings.first if found_settings.any?
    #   return node['chef-git-server'][method_name.to_s] unless node['chef-git-server'][method_name.to_s].nil?
    #   raise UnknownWorkUserSetting, [method_message, caller].join("\n")
    # end
  end
end
