# 
# Cookbook Name:: inmobi_lb
#

rightscale_marker :begin

class Chef::Recipe
  include Inmobi::LB::Helper
end

def vhosts(vhost_list)
   return vhost_list.gsub(/\s+/, "").split(",").uniq.each
end

DROP_THRESHOLD = 3

# Iterate through each vhost.
vhosts(node[:app_inmobi_lb][:vhost_names]).each do |vhost_name|

  log "Attach all for [#{vhost_name}]"
  # Obtain current list from lb config file.
  inconfig_servers = get_attached_servers(vhost_name)
  log "  Currently attached: #{inconfig_servers.nil? ? 0 : inconfig_servers}"

  # Obtain list of app servers in deployment.
  deployment_servers = query_appservers(vhost_name)

  # Send warning if no application servers are found.
  log "  No application servers found" do
    only_if { deployment_servers.empty? }
    level :warn
  end

  # Add any servers in deployment not in config.
  servers_to_attach = Set.new(deployment_servers.keys) - inconfig_servers
  log "  No servers to attach" do
    only_if { servers_to_attach.empty? }
  end
  servers_to_attach.each do |uuid|
    inmobi_lb vhost_name do
      backend_id uuid
      backend_ip deployment_servers[uuid][:ip]
      backend_port deployment_servers[uuid][:backend_port].to_i
      action :attach
    end
  end

  # Increment threshold counter if servers in config not in deployment.
  node[:app_inmobi_lb][:threshold] ||= Hash.new
  node[:app_inmobi_lb][:threshold][vhost_name] ||= Hash.new
  servers_missing = inconfig_servers - Set.new(deployment_servers.keys)
  servers_missing.each do |uuid|
    node[:app_inmobi_lb][:threshold][vhost_name][uuid].is_a?(Integer) ? node[:app_inmobi_lb][:threshold][vhost_name][uuid] += 1 : node[:app_inmobi_lb][:threshold][vhost_name][uuid] = 1
    log "  Increment threshold counter for #{uuid} = #{node[:app_inmobi_lb][:threshold][vhost_name][uuid]}"
  end

  # Set threshold counters to nil to those not incremented, thus assuming app server now accessable.
  # Set to nil since chef does not delete the key, can only alter it.
  (Set.new(node[:app_inmobi_lb][:threshold][vhost_name].keys)-servers_missing).each do |uuid|
    if node[:app_inmobi_lb][:threshold][vhost_name][uuid]
      node[:app_inmobi_lb][:threshold][vhost_name][uuid] = nil
      log "  Resetting threshold for #{uuid}"
    end
  end

  # Delete servers that hit threshold.
  app_servers_detached = 0
  node[:app_inmobi_lb][:threshold][vhost_name].each do |uuid, counter|
    if counter == nil
      next
    elsif counter >= DROP_THRESHOLD
      log "  Threshold of #{DROP_THRESHOLD} reached for #{uuid} (#{node[:app_inmobi_lb][:threshold][vhost_name][uuid]}) - detaching"
      inmobi_lb vhost_name do
        backend_id uuid
        action :detach
      end
      node[:app_inmobi_lb][:threshold][vhost_name][uuid] = nil # Set to nil - chef does not delete the key, can only alter it.
      app_servers_detached += 1
    else
      log "  Threshold not reached for #{uuid} : #{node[:app_inmobi_lb][:threshold][vhost_name][uuid]}"
    end
  end

  log "  No servers to detach" do
    only_if { app_servers_detached == 0 }
  end

end

rightscale_marker :end

