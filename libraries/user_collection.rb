
module ChefGitServer
  class UserCollection
    include ChefGitServer::NodeDataBag

    attr_reader :users

    def initialize(category, new_context)
      unless new_context.nil?
        assigned_run_context(new_context)
        Chef::Log.warn("Fetching developper category #{category}")
        @users = node['workspace'][category].map do |login|
          ChefGitServer::WorkUser.new(login, new_context)
        end
      end
    end

    def each
      users.each do |developper|
        yield(developper) if block_given?
      end
    end
  end
end
