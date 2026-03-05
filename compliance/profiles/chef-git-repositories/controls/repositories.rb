# Cookbook:: chef-git-server

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

repository_groups = input('use_repository_group', value: []).map do |repo|
  [repo, input(repo, value: nil)]
end

repository_groups.each do |repository_group, repositories|
  control "#{repository_group}_repositories_control" do
    impact 0.7
    title "Repository Control for #{repository_group}"
    desc "This is the repository control. Test if repository exist as per define by repositories input"

    repositories.each do |repository_name|
      describe directory(File.join('/home/git', "#{repository_name}.git")) do
        it { should exist }
      end
    end
  end
end
