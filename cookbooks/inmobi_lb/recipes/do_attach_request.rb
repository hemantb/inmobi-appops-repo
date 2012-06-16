# 
# Cookbook Name:: inmobi_lb
#

rightscale_marker :begin

def vhosts(vhost_list)
  return vhost_list.gsub(/\s+/, "").split(",").uniq.each
end

vhosts(node[:inmobi_lb][:vhost_names]).each do |vhost_name|
  log "  Adding tag to answer for vhost load balancing - #{vhost_name}."
  lb_tag vhost_name

  log "  Sending remote attach request..."
  inmobi_lb vhost_name do
    backend_id node[:rightscale][:instance_uuid]
    backend_ip node[:app][:ip]
    backend_port node[:app][:port].to_i
    service_region node[:inmobi_lb][:service][:region]
    service_lb_name node[:inmobi_lb][:service][:inmobi_lb_name]
    service_account_id node[:inmobi_lb][:service][:account_id]
    service_account_secret node[:inmobi_lb][:service][:account_secret]
    action :attach_request
  end
end

rightscale_marker :end
