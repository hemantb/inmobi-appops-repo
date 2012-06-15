# 
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

def vhosts(vhost_list)
  return vhost_list.gsub(/\s+/, "").split(",").uniq.each
end

log "  Remote recipe executed by do_attach_request"
vhosts(node[:remote_recipe][:vhost_names]).each do |vhost_name|
  inmobi_lb vhost_name do
    backend_id node[:remote_recipe][:backend_id]
    backend_ip node[:remote_recipe][:backend_ip]
    backend_port node[:remote_recipe][:backend_port].to_i
    session_sticky node[:inmobi_lb][:session_stickiness]
    action :attach
  end
end

rightscale_marker :end
