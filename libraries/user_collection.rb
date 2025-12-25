
module Workspace
  class UserCollection
    include Workspace::NodeDataBag

    attr_reader :users

    def initialize(category)
      @users = node['workspace'][category].map do |login|
        Workspace::WorkUser.new(login)
      end
    end

    def each
      users.each do |developper|
        yield(developper) if block_given?
      end
    end
  end
end
