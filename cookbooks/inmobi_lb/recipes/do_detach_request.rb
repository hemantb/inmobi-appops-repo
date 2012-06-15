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

vhosts(node[:inmobi_lb][:vhost_names]).each do |vhost_name|
  log "  Remove the load balancing tags, so we will not be re-attached. - #{vhost_name}"
  lb_tag vhost_name do
    action :remove
  end

  log "  Sending remote detach request..."
  inmobi_lb vhost_name do
    backend_id node[:rightscale][:instance_uuid]
    backend_ip node[:app][:ip]
    backend_port node[:app][:port].to_i
    service_region node[:inmobi_lb][:service][:region]
    service_lb_name node[:inmobi_lb][:service][:inmobi_lb_name]
    service_account_id node[:inmobi_lb][:service][:account_id]
    service_account_secret node[:inmobi_lb][:service][:account_secret]
    action :detach_request
  end
end

rightscale_marker :end
