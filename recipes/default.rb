#
# Cookbook Name:: chef-git-server
# Recipe:: default
#
#

chef_git_server 'default' do
  repositories node[cookbook_name]['repositories']
  user node[cookbook_name]['user']
  group node[cookbook_name]['group']
  home node[cookbook_name]['home']
  shell node[cookbook_name]['shell']
  user_comment node[cookbook_name]['user_comment']
  userdatabag node[cookbook_name]['userdatabag']
  userdatabagkey node[cookbook_name]['userdatabagkey']
  compile_time node[cookbook_name]['compile_time']
  userdatabag node[cookbook_name]['userdatabag']
  secretdatabag node[cookbook_name]['secretdatabag']
  secretdatabagitem node[cookbook_name]['secretdatabagitem']
  secretdatabagkey node[cookbook_name]['secretdatabagkey']
  action [:install, :update_users]
end
