# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "chef-git-server"
  spec.version       = "0.1.1"
  spec.authors       = [ "Jimmy Provencher" ]
  spec.email         = [ "jimmy.provencher@hotmail.ca" ]

  spec.rubygems_version          = ">= 3.1.0"
  spec.required_ruby_version     = ">= 3.1.0"
  spec.required_rubygems_version = ">= 3.3.3"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/JimboDragonGit/chef-git-server/issues",
    "changelog_uri" => "https://github.com/JimboDragonGit/chef-git-server/issues",
    "documentation_uri" => "https://github.com/JimboDragonGit/chef-git-server/issues",
    "homepage_uri" => "https://github.com/JimboDragonGit/chef-git-server/issues",
    "mailing_list_uri" => "https://github.com/JimboDragonGit/chef-git-server/issues",
    "source_code_uri" => "https://github.com/JimboDragonGit/chef-git-server/issues",
    "wiki_uri" => "https://github.com/JimboDragonGit/chef-git-server/issues",
    "funding_uri" => "https://github.com/JimboDragonGit/chef-git-server/issues",
    "allowed_push_host" => "https://jimbodragon.qc.to/artifactory/api/gems/gems-local"
  }

  spec.summary       = "Gem to be introduced in Chef, Kitchen, knife, Cucumber and Inspec"
  spec.description   = 'Overlaps with Chef, Kitchen, knife, Cucumber and Inspec. This is a build library to be used in\n
all Chef, Kitchen, knife, Cucumber and Inspec projects.
  It is a gem to be used in the Chef ecosystem, providing a foundation for building and managing Chef-related projects.
  It includes tools and utilities to streamline the development and testing of Chef cookbooks, recipes,\n
and configurations.
  It is designed to enhance the Chef development experience by providing a consistent and efficient way \n
to manage Chef projects.
  '
  spec.homepage      = "https://jimbodragon.qc.to"
  spec.license       = "Apache-2.0"

  spec.files         = (
                          Dir.glob("librairies/*.rb") +
                          [ "README.md", "LICENSE", "CHANGELOG.md" ]
                       )
  # spec.bindir        = "exe"
  # spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  # spec.require_paths = [ "features/support" ]

  # Runtime dependencies for the project itself
  spec.add_runtime_dependency "inifile", "~> 3" # '~> 3.0'
  spec.add_runtime_dependency "os", "~> 1" # '~> 1.1.4'

  # Runtime dependencies for AWS
  spec.add_runtime_dependency "aws-sdk", "~> 3"

  # Runtime dependencies for Chef
  spec.add_runtime_dependency "berkshelf", "~> 8"
  spec.add_runtime_dependency "chef", "~> 18"
  spec.add_runtime_dependency "chef-cli", "~> 5"
  spec.add_runtime_dependency "knife", "~> 18"
  spec.add_runtime_dependency "knife-vsphere", "~> 5"
  spec.add_runtime_dependency "test-kitchen", "~> 3", "~> 3.7", "!= 3.9.1"
  spec.add_runtime_dependency "kitchen-ec2", "~> 3"
  spec.add_runtime_dependency "kitchen-inspec", "~> 3"
  spec.add_runtime_dependency "kitchen-vagrant", "~> 2"
  spec.add_runtime_dependency "kitchen-dokken", "~> 2"

  spec.add_runtime_dependency "brakeman"

  spec.add_runtime_dependency "unix-crypt"
  spec.add_runtime_dependency "ruby-shadow"
  spec.add_runtime_dependency "chef-vault"
  spec.add_runtime_dependency "veil"

  # Additional runtime dependencies for debugging, development, and code analysis
  spec.add_runtime_dependency "debug", "~> 1"
  spec.add_runtime_dependency "rake-release", "~> 1"
  spec.add_runtime_dependency "ruby-lsp-rails", "~> 0"
  spec.add_runtime_dependency "solargraph", "~> 0"
end
