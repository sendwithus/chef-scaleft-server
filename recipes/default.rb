#
# Cookbook:: chef-scaleft-server
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
case node['platform_family']
when'rhel'
  yum_repository 'scaleft' do
    description 'Official Scaleft Yum repository'
    baseurl 'https://pkg.scaleft.com/rpm/'
    gpgkey 'https://dist.scaleft.com/pki/scaleft_rpm_key.asc'
    action :create
    gpgcheck true
  end
else
  fail "Platform #{node['platform_family']} is not supported"
end

directory '/etc/sft/' do
  action :create
end

directory '/var/lib/sftd/' do
  action :create
end

package 'scaleft-server-tools' do
  action :install
end

service 'sftd' do
  action [:enable, :start]
end

template '/etc/sft/sftd.yaml' do
  source 'sftd.yaml.erb'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  notifies :restart, 'service[sftd]', :delayed
end

template '/var/lib/sftd/enrollment.token' do
  source 'enrollment.token.erb'  
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  notifies :restart, 'service[sftd]', :delayed
  not_if { node[:scaleft][:enrollment_token].nil? }
end
