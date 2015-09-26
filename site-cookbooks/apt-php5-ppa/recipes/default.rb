#
# Cookbook Name:: apt-php5-ppa
# Recipe::default
#
# Author: Kamil Tunkiewicz
#

include_recipe "apt"

package "python-software-properties" do
    action :install
end

apt_repository "ondrej-php-precise" do
    uri "http://ppa.launchpad.net/ondrej/php5-5.6/ubuntu"
    distribution "precise"
    components ["main"]
    keyserver "keyserver.ubuntu.com"
    key "E5267A6C"
end

[ "php5", "php5-mysql", "php5-curl", "php5-mcrypt" ].each do |pkg|
    package pkg do
        action :install
        version "5.6.*"
        notifies :restart, "service[nginx]", :delayed
        notifies :run, "execute[apt-get autoremove]", :delayed
    end
end
