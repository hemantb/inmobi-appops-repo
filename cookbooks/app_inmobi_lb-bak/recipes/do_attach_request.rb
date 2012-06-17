# 
# Cookbook Name:: app_inmobi_lb
#

rightscale_marker :begin

def vhosts(vhost_list)
  return vhost_list.gsub(/\s+/, "").split(",").uniq.each
end

vhosts(node[:app_inmobi_lb][:vhost_names]).each do |vhost_name|
  log "  Adding tag to answer for vhost load balancing - #{vhost_name}."
  lb_tag vhost_name

  log "  Sending remote attach request..."
  app_inmobi_lb vhost_name do
    backend_id node[:rightscale][:instance_uuid]
    backend_ip node[:app][:ip]
    action :attach_request
  end
end

rightscale_marker :end
