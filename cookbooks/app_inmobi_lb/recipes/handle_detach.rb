# 
# Cookbook Name:: inmobi_lb
#

rightscale_marker :begin

def vhosts(vhost_list)
  return vhost_list.gsub(/\s+/, "").split(",").uniq.each
end

log "Remote recipe executed by do_detach_request"

vhosts(node[:remote_recipe][:vhost_names]).each do |vhost_name|
  inmobi_lb vhost_name do
    backend_id node[:remote_recipe][:backend_id]
    action :detach
  end
end

rightscale_marker :end
