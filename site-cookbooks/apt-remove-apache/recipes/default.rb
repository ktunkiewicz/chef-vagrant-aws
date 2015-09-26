#
# Cookbook Name:: apt-remove-apache
# Recipe::default
#
# Author: Kamil Tunkiewicz
#

package "apache2" do
    action :remove
    notifies :run, "execute[apt-get autoremove]", :delayed
end
