# Cookbook:: chef-git-server

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

repositories = input('repositories', value: [])

control 'repositories_control' do
  impact 0.7
  title 'Repository Control'
  desc 'This is the repository control. Test if repository exist as per define by repositories input'

  repositories.each do |repository_name|
    describe directory(File.join('/home/git', "#{repository_name}.git")) do
      it { should exist }
    end
  end
end
