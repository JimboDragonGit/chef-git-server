# Chef InSpec test for recipe root_workspace::default

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

# This is an example test, replace it with your own test.
describe port(22) do
  it { should be_listening }
end
