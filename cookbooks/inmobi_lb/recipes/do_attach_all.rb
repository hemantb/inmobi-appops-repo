# 
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

class Chef::Recipe
  include RightScale::LB::Helper
end

def vhosts(vhost_list)
   return vhost_list.gsub(/\s+/, "").split(",").uniq.each
end

DROP_THRESHOLD = 3

# Iterate through each vhost.
vhosts(node[:inmobi_lb][:vhost_names]).each do |vhost_name|

  log "Attach all for [#{vhost_name}]"
  # Obtain current list from lb config file.
  inconfig_servers = get_attached_servers(vhost_name)
  log "  Currently attached: #{inconfig_servers.nil? ? 0 : inconfig_servers.count}"

end

  # Obtain list of app servers in deployment.

rightscale_marker :end

