# 
# Cookbook Name:: inmobi_lb
#

rightscale_marker :begin

class Chef::Recipe
  include Inmobi::LB::Helper
end

log "Remote recipe executed by do_detach_request"

vhosts(node[:remote_recipe][:vhost_names]).each do |vhost_name|
  app_inmobi_lb vhost_name do
    backend_id node[:remote_recipe][:backend_id]
    action :detach
  end
end

rightscale_marker :end
