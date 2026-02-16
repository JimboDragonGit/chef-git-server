
module ChefGitServer
  class UserCollection
    include ChefGitServer::NodeDataBag

    attr_reader :users

    def initialize(category)
      @users = node['workspace'][category].map do |login|
        ChefGitServer::WorkUser.new(login)
      end
    end

    def each
      users.each do |developper|
        yield(developper) if block_given?
      end
    end
  end
end
