
module ChefGitServer
  class UserCollection
    include ChefGitServer::NodeDataBag
    include ChefGitServer::ChefContextHelpers

    attr_reader :users

    def initialize(category, new_context)
      @chef_run_context = new_context
      Chef::Log.warn("Fetching developper category #{category}")
      @users = node['workspace'][category].map do |login|
        ChefGitServer::WorkUser.new(login, new_context)
      end
    end

    def each
      users.each do |developper|
        yield(developper) if block_given?
      end
    end

    def map
      users.map do |developper|
        yield(developper) if block_given?
      end
    end

    def select
      users.select do |developper|
        yield(developper) if block_given?
      end
    end
  end
end
