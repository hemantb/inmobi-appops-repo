#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Stop tomcat service
action :stop do
  log "  Running stop sequence"
  service "tomcat6" do
    action :stop
    persist false
  end
end

# Start tomcat service
action :start do
  log "  Running start sequence"
  service "tomcat6" do
    action :start
    persist false
  end

end

# Restart tomcat service
action :restart do
  log "  Running restart sequence"
  action_stop
     sleep 5
  action_start
end


#Installing required packages and prepare system for tomcat
action :install do

  packages = new_resource.packages
  log "  Packages which will be installed: #{packages}"
  packages .each do |p|
    log "installing #{p}"
    package p

  end
  # Executing java alternatives command, this will set installed java as choose as default
  execute "alternatives" do
    command "#{node[:app_tomcat][:alternatives_cmd]}"
    action :run
  end

end

# Setup tomcat configuration files
action :setup_config do

  log "  Creating /etc/default/tomcat6"
  template "/etc/default/tomcat6" do
    action :create
    source "tomcat6_default.erb"
    group "root"
    owner "root"
    mode "0644"
    cookbook 'app_tomcat'
    variables(
      :app_user => node[:app_tomcat][:app_user],
      :app_group => node[:app_tomcat][:app_group]
    )
  end

  log "  Creating /etc/init.d/tomcat6"
  template "/etc/tomcat6/tomcat6.conf" do
    action :create
    source "tomcat6_conf.erb"
    group "root"
    owner "root"
    mode "0644"
    cookbook 'app_tomcat'
    variables(
      :app_user => node[:app_tomcat][:app_user],
      :java_xmx => node[:app_tomcat][:java][:xmx],
      :java_maxpermsize => node[:app_tomcat][:java][:maxpermsize],
      :java_jmx_port => node[:app_tomcat][:java][:jmx_port],
      :java_heamdumppath => node[:app_tomcat][:java][:heapdumppath],
      :host_ip => node[:ip]
    )
  end

  log "  Creating server.xml"
  template "/etc/tomcat6/server.xml" do
    action :create
    source "server_xml.erb"
    group "root"
    owner "#{node[:app_tomcat][:app_user]}"
    mode "0644"
    cookbook 'app_inmobi_tomcat'
    variables(
            :doc_root => node[:app][:root],
            :app_port => node[:app][:port]
          )
  end

  # Re-starting tomcat service
  action_restart

end
