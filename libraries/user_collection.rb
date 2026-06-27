
module ChefGitServer
  class UserCollection
    include ChefGitServer::NodeDataBag
    include ChefGitServer::ChefContextHelpers

    class MissingCategory < StandardError; end

    attr_reader :users

    def initialize(category, new_context)
      @chef_run_context = new_context
      Chef::Log.warn("Fetching developper category #{category}")
      begin
        @users = node['workspace'][category].map do |login|
          ChefGitServer::WorkUser.new(login, new_context)
        end
      rescue NoMethodError => e
        raise MissingCategory, "Missing category #{category} as per error #{e.message}"
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

    def reject
      users.reject do |developper|
        yield(developper) if block_given?
      end
    end
  end
end
