# Cookbook:: chef-git-server

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

control 'server_control' do
  impact 0.7
  title 'Git Server Control'
  desc 'This is control the git server.'

  describe user('git') do
    it { should exist }
    its('group') { should eq 'git' }
    its('groups') { should eq ['git']}
    its('home') { should eq '/home/git' }
    its('shell') { should eq '/usr/bin/git-shell' }
    its('mindays') { should eq 0 }
    its('maxdays') { should eq 99999 }
    its('warndays') { should eq 7 }
    its('passwordage') { should be >= 1 }
    its('badpasswordattempts') { should eq 0 }
  end

  describe group('git') do
    it { should exist }
  end

  describe port(22) do
    it { should be_listening }
  end

  describe directory('/home/git') do
    it { should exist }
    its('owner') { should eq 'git' }
    its('group') { should eq 'git' }
    its('mode') { should cmp '488' }
  end

  describe file('/usr/bin/git-shell') do
    it { should exist }
  end
end
