
module Workspace
  class WorkUser
    include Workspace::NodeDataBag

    attr_reader :login, :chef_node

    def initialize(login)
      @login = login
    end

    def sandbox_folder
      private_info.key?(__method__) ? private_info[__method__] : Dir.mktmpdir
    end

    def env_folder
      private_info[__method__]
    end

    def group
      private_info[__method__]
    end

    def email
      private_info[__method__]
    end

    def firstname
      private_info[__method__]
    end

    def lastname
      private_info[__method__]
    end

    def user_env
      private_info['env']
    end

    def ssh_private_key
      private_info[__method__]
    end

    def ssh_public_key
      private_info[__method__]
    end

    def home
      user_env['HOME']
    end

    def run_command(command, working_dir)
      Chef::Log.warn("Executing the command '#{command}'")
      Mixlib::ShellOut.new(command, cwd: working_dir, environment: user_env).run_command
    end

    def run_command!(command, working_dir)
      Chef::Log.warn("Hoping that the command '#{command}' does not failed")
      Mixlib::ShellOut.new(command, cwd: working_dir, environment: user_env).run_command.error!
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
  end
end
