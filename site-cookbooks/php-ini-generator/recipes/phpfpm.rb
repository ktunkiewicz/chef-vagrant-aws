#
# Cookbook Name:: php-ini-generator
# Recipe:: phpfpm
#
# Author: Kamil Tunkiewicz
#

directory '/etc/php5/fpm' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
end

template "/etc/php5/fpm/php.ini" do
    source "phpfpm/#{node.provider}.erb"
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'service[php-fpm]', :delayed
end


