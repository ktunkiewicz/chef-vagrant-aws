#
# Cookbook Name:: php-ini-generator
# Recipe:: hhvm
#
# Author: Kamil Tunkiewicz
#

directory '/etc/php5/hhvm' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
end

template "/etc/php5/hhvm/php.ini" do
    source "hhvm/#{node.provider}.erb"
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'service[hhvm]', :delayed
end

execute 'create_hhvm_defaults' do
  command 'echo "SYSTEM_CONFIG_FILE=/etc/php5/hhvm/php.ini" > /etc/default/hhvm'
  notifies :restart, 'service[hhvm]', :delayed
  action :run
end

