# name 'Helper file for chef-git-server'
# maintainer 'Jimbo Dragon'
# maintainer_email 'jimbo_dragon@hotmail.com'
# license 'MIT'
# description 'Helper file for chef-git-server'
# version '0.1.0'
# chef_version '>= 16.6.14'
# issues_url 'https://github.com/jimbodragon/chef-git-server/issues'
# source_url 'https://github.com/jimbodragon/chef-git-server'
#
# Chef Infra Documentation
# https://docs.chef.io/libraries/
#

#
# This module name was auto-generated from the cookbook name. This name is a
# single word that starts with a capital letter and then continues to use
# camel-casing throughout the remainder of the name.
#
module ChefGitServer
  module SshKeysHelpers
    #
    # Define the methods that you would like to assist the work you do in recipes,
    # resources, or templates.
    #
    # def my_helper_method
    #   # help method implementation
    # end

    attr_accessor :sshkeys

    def ssh_keys(new_resource)
      begin
        Chef::Log.warn("Fetch git ssh users")
        @ssh_keys = ''
        users = data_bag(new_resource.user_data_bag)
        Chef::Log.warn("Fetch git ssh users #{users}")
        users.each do |username|
          Chef::Log.warn("Fetch git ssh keys for user #{username}")
          user = data_bag_item(new_resource.user_data_bag, username)
          Chef::Log.warn("Fetch git ssh keys for user #{username} = Hash #{user.to_hash} in #{new_resource.user_data_bag}/#{new_resource.ssh_keyname_data_bag}")
          # Chef::Log.warn("Fetch git ssh keys for user #{username} = key #{user.key}")
          Chef::Log.warn("Fetch git ssh keys for user #{username} = keys #{user.keys} in #{new_resource.user_data_bag}/#{new_resource.ssh_keyname_data_bag}")
          Chef::Log.warn("Fetch git ssh keys for user #{username} = values #{user.values} in #{new_resource.user_data_bag}/#{new_resource.ssh_keyname_data_bag}")
          user[new_resource.ssh_keyname_data_bag].each do |ssh_key|
            Chef::Log.warn("Adding git ssh keys for user #{username} = #{user} with value #{ssh_key} in #{new_resource.user_data_bag}/#{new_resource.ssh_keyname_data_bag}")
            @ssh_keys << ssh_key + "\n"
          end if user.keys.include?(new_resource.ssh_keyname_data_bag)
        end
      rescue Exception => e
        @ssh_keys = "Error running ChefGitServer::SshKeysHelpers.ssh_keys with exception #{e.message} with #{ @ssh_keys } in #{new_resource.user_data_bag}/#{new_resource.ssh_keyname_data_bag}"
      end
      @ssh_keys
    end
  end
end

#
# The module you have defined may be extended within the recipe to grant the
# recipe the helper methods you define.
#
# Within your recipe you would write:
#
#     extend ChefGitServer::SshKeysHelpers
#
#     my_helper_method
#
# You may also add this to a single resource within a recipe:
#
#     template '/etc/app.conf' do
#       extend ChefGitServer::SshKeysHelpers
#       variables specific_key: my_helper_method
#     end
#
