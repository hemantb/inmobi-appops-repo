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

vhosts(node[:app_inmobi_lb][:vhost_names]).each do |vhost_name|
  log "  Remove the load balancing tags, so we will not be re-attached. - #{vhost_name}"
  lb_tag vhost_name do
    action :remove
  end

  log "  Sending remote detach request..."
  app_inmobi_lb vhost_name do
    backend_id node[:rightscale][:instance_uuid]
    backend_ip node[:app][:ip]
    action :detach_request
  end
end

rightscale_marker :end
