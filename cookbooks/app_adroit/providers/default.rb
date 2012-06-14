#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Stop services
action :stop do
  log "  Running stop sequence"
  service "tomcat6" do
    action :stop
    persist false
  end
end

# Start services
action :start do
  log "  Running start sequence"
  service "tomcat6" do
    action :start
    persist false
  end

end

# Restart services
action :restart do
  log "  Running restart sequence"
  action_stop
     sleep 5
  action_start
end


#Installing specified packages
action :install do
  packages = new_resource.packages
  log "  Packages which will be installed: #{packages}"
  packages .each do |p|
    log "installing #{p}"
    package p
end
