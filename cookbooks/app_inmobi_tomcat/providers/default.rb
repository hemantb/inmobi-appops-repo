#
# Cookbook Name:: app_inmobi_tomcat
#
# Copyright Inmobi, Inc. All rights reserved.
# Author: Bhagyaraj.g

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
  log "  Running apt-get update"

  execute "update apt cache" do
    command "apt-get update"
    ignore_failure true
  end

  service "tomcat6" do
    action :nothing
  end

  log "  Packages which will be installed: #{packages}"
  packages .each do |p|
    log "installing #{p}"
    case p
    when "sun-java6-jre"
        log "Setting debconf parameters to automate #{p} installation"
        bash "update-debconf-set-selections" do
            code <<-EOF
            echo 'sun-java6-bin shared/accepted-sun-dlj-v1-1 boolean true
            sun-java6-jdk shared/accepted-sun-dlj-v1-1 boolean true
            sun-java6-jre shared/accepted-sun-dlj-v1-1 boolean true
            sun-java6-jre sun-java6-jre/stopthread boolean true
            sun-java6-jre sun-java6-jre/jcepolicy note
            sun-java6-bin shared/present-sun-dlj-v1-1 note
            sun-java6-jdk shared/present-sun-dlj-v1-1 note
            sun-java6-jre shared/present-sun-dlj-v1-1 note'|debconf-set-selections
            EOF
       end
       sleep 5
    end

    package p do
	options "--force-yes"
	action :install
        notifies :restart , resources(:service => "tomcat6")
    end

  end

  # Executing java alternatives command, this will set installed java as choose as default
  execute "update-alternatives" do
    command "#{node[:app_inmobi_tomcat][:alternatives_cmd]}"
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
    variables(
      :app_user => node[:app_inmobi_tomcat][:app_user],
      :app_group => node[:app_inmobi_tomcat][:app_group]
    )
    notifies :restart , "service[tomcat6]"
  end

  log "  Creating /etc/init.d/tomcat6 with host_ip like #{node[:app][:ip]}"
  template "/etc/init.d/tomcat6" do
    action :create
    source "tomcat6_init.erb"
    group "root"
    owner "root"
    mode "0755"
    variables(
      :app_user => node[:app_inmobi_tomcat][:app_user],
      :java_xmx => node[:app_inmobi_tomcat][:java][:xmx],
      :java_maxpermsize => node[:app_inmobi_tomcat][:java][:maxpermsize],
      :java_jmx_port => node[:app_inmobi_tomcat][:java][:jmxport],
      :java_heapdumppath => node[:app_inmobi_tomcat][:java][:heapdumppath],
      :java_extraopts => node[:app_inmobi_tomcat][:java][:extraopts],
      :host_ip => node[:app][:ip]
    )
    notifies :restart , "service[tomcat6]"
  end

  log "  Creating server.xml"
  template "/etc/tomcat6/server.xml" do
    action :create
    source "tomcat6_server_xml.erb"
    group "root"
    owner "#{node[:app_inmobi_tomcat][:app_user]}"
    mode "0644"
    variables(
            :doc_base => node[:app_inmobi_tomcat][:base],
            :app_port => node[:app_inmobi_tomcat][:port]
          )
    notifies :restart , "service[tomcat6]"
  end

  service "tomcat6"
end

# Setup monitoring tools for tomcat
action :setup_monitoring do

  log "  Setup of collectd monitoring for tomcat"
  rightscale_enable_collectd_plugin 'exec'

  #installing and configuring collectd for tomcat
  remote_file "/usr/share/java/collectd.jar" do
    source "collectd.jar"
    mode "0644"
  end

  #Linking collectd
  link "/usr/share/tomcat6/lib/collectd.jar" do
    to "/usr/share/java/collectd.jar"
    not_if do !::File.exists?("/usr/share/java/collectd.jar") end
  end

  #Add collectd support to tomcat.conf
  bash "Add collectd to tomcat.conf" do
    code <<-EOH
      cat <<'EOF'>>/etc/tomcat6/tomcat6.conf
      CATALINA_OPTS="\$CATALINA_OPTS -Djcd.host=#{node[:rightscale][:instance_uuid]} -Djcd.instance=tomcat6 -Djcd.dest=udp://#{node[:rightscale][:servers][:sketchy][:hostname]}:3011 -Djcd.tmpl=javalang,tomcat -javaagent:/usr/share/tomcat6/lib/collectd.jar"
      EOF
    EOH
  end

end
