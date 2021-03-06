# 
# Cookbook Name:: inmobi_lb
#

rightscale_marker :begin

class Chef::Recipe
  include Inmobi::LB::Helper
end

include_recipe "app_inmobi_lb::default"

log "  Install load balancer"

# In the 'install' action, the name is not used, but the provider from default recipe is needed.
# Any vhost name set with provider can be used. Using first one in list to make it simple.
log "Installing software #{node[:app_inmobi_lb][:vhost_names]}"

app_inmobi_lb vhosts(node[:app_inmobi_lb][:vhost_names]).first do
  action :install
end

log "Adding vhosts"

vhosts(node[:app_inmobi_lb][:vhost_names]).each do |vhost_name|
  app_inmobi_lb vhost_name do
    action :add_vhost
  end
end

include_recipe "app_inmobi_lb::setup_monitoring"

rightscale_marker :end
