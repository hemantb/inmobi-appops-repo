# 
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

include_recipe "inmobi_lb::default"

def vhosts(vhost_list)
  return vhost_list.gsub(/\s+/, "").split(",").uniq.each
end

VHOST_NAMES = node[:inmobi_lb][:vhost_names]

log "  Install load balancer"

# In the 'install' action, the name is not used, but the provider from default recipe is needed.
# Any vhost name set with provider can be used. Using first one in list to make it simple.
log "Installing software #{VHOST_NAMES}"

#inmobi_lb vhosts(VHOST_NAMES).first do
#  action :install
#end


#log "Adding vhosts"

#vhosts(VHOST_NAMES).each do |vhost_name|
#  inmobi_lb vhost_name do
#    action :add_vhost
#  end
#end

rightscale_marker :end
