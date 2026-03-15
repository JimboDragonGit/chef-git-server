
module ChefGitServer
  class WorkUser
    include ChefGitServer::NodeDataBag

    class UnknownWorkUserSetting < RuntimeError; end

    attr_reader :login, :chef_node

    def initialize(login)
      @login = login
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

    def authorized_ssh_users
      private_info[__method__]
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

    private
    def private_info
      case ::ChefVault::Item.data_bag_item_type(userdatabag, login)
      when :normal
        data_bag_item(userdatabag, login)
      when :encrypted
        data_bag_item(userdatabag, login, get_secret).to_h
      when :vault
        ::ChefVault::Item.load(userdatabag, login).to_h
      end
    end

    def method_missing(method_name, *argv, &block)
      found_settings = [method_name, method_name.to_s].select do |mn|
        private_info.key?(mn)
      end
      return found_settings.first if found_method.any?
      raise UnknownWorkUserSetting, "method_name #{method_name}(with #{argv.count} parameters) is unavailable"
    end
  end
end
