# 
# Cookbook Name:: lb_haproxy
#

action :install do

  log "  Installing haproxy"

  depends = ["libc6", "libc6-dev", "gcc", "mkhoj-base"]

  depends.each do |p|
    package p do
      options "--force-yes"
    end
  end

  remote_file "/tmp/haproxy-1.4.21.tar.gz" do
    source "haproxy-1.4.21.tar.gz"
    mode "0755"
  end

  if node[:app_inmobi_lb][:installed] && node[:app_inmobi_lb][:installed] != "true"
    script "install_haproxy_server" do
     interpreter "bash -ex"
      code <<-EOF
        cd /tmp
        tar -zxvf haproxy-1.4.21.tar.gz
        cd haproxy-1.4.21
        echo "running make" >> /opt/mkhoj/logs/haproxy_install_log
        date >> /opt/mkhoj/logs/haproxy_install_log
        make TARGET=linux26 >> /opt/mkhoj/logs/haproxy_install_log
        echo "running make install" >> /opt/mkhoj/logs/haproxy_install_log
        make install PREFIX=/opt/mkhoj >> /opt/mkhoj/logs/haproxy_install_log
        touch /etc/init.d/haproxy
      EOF
    end
  else
    log "HAProxy 1.4.21 has already been installed once. Not installing again"
  end

  user "haproxy" do
    comment "haproxy service"
    system true
    shell "/bin/false"
    action :create
  end

  group "haproxy" do
    system true
    action :create
    members ['haproxy']
  end

  # Create haproxy service.
  service "haproxy" do
    supports :restart => true, :status => true, :start => true, :stop => true
    action :enable
  end

  # Install haproxy file depending on OS/platform.
  template "/etc/init.d/haproxy" do
    source "haproxy.init.erb"
    mode 0755
    notifies :restart, resources(:service => "haproxy")
  end

  template "/etc/default/haproxy" do
    only_if { node[:platform] == "debian" || node[:platform] == "ubuntu" }
    source "default_haproxy.erb"
    owner "root"
    notifies :restart, resources(:service => "haproxy")
  end

  # Create /opt/mkhoj/conf/lb directory.
  directory "/opt/mkhoj/conf/lb/lb_haproxy.d" do
    owner "haproxy"
    group "haproxy"
    mode 0755
    recursive true
    action :create
  end

  # Install script that concatenates individual server files after the haproxy config head into the haproxy config.
  template "/opt/mkhoj/conf/lb/haproxy-genconf.pl" do
    owner "haproxy"
    group "haproxy"
    mode 0755
    source "haproxy-genconf.pl"
  end

  # Install the haproxy config head which is the part of the haproxy config that doesn't change.
  template "/opt/mkhoj/conf/lb/inmobi_lb.cfg.head" do
    source "haproxy_http.erb"
    owner "haproxy"
    group "haproxy"
    mode "0400"
    stats_file="stats socket #{node[:app_inmobi_lb][:cfg_dir]}/status user haproxy group haproxy"
    variables(
      :stats_file_line => stats_file
    )
  end

  # Install the haproxy config head which is the part of the haproxy config that doesn't change.
  template "/opt/mkhoj/conf/lb/inmobi_lb.cfg.default_backend" do
    source "haproxy_default_backend.erb"
    owner "haproxy"
    group "haproxy"
    mode "0400"

    default_backend = node[:app_inmobi_lb][:vhost_names].gsub(/\s+/, "").split(",").first.gsub(/\./, "_") + "_backend"
    variables(
      :default_backend_line => default_backend
    )
  end

  node[:app_inmobi_lb][:installed] = "true"

end # action :install do

action :add_vhost do

  vhost_name = new_resource.vhost_name

  # Create the directory for vhost server files.
  directory "/opt/mkhoj/conf/lb/lb_haproxy.d/#{vhost_name}" do
    owner "haproxy"
    group "haproxy"
    mode 0755
    recursive true
    action :create
  end

  # Create backend haproxy files for vhost it will answer for.
  template ::File.join("/opt/mkhoj/conf/lb/lb_haproxy.d", "#{vhost_name}.cfg") do
    source "haproxy_backend.erb"
    owner "haproxy"
    group "haproxy"
    mode "0400"
    backend_name = vhost_name.gsub(".", "_") + "_backend"
    stats_uri = "stats uri #{node[:app_inmobi_lb][:stats_uri]}" unless "#{node[:app_inmobi_lb][:stats_uri]}".empty?
    stats_auth = "stats auth #{node[:app_inmobi_lb][:stats_user]}:#{node[:app_inmobi_lb][:stats_password]}" unless \
                "#{node[:app_inmobi_lb][:stats_user]}".empty? || "#{node[:app_inmobi_lb][:stats_password]}".empty?
    health_uri = "option httpchk GET #{node[:app_inmobi_lb][:health_check_uri]}" unless "#{node[:app_inmobi_lb][:health_check_uri]}".empty?
    health_chk = "http-check disable-on-404" unless "#{node[:app_inmobi_lb][:health_check_uri]}".empty?
    variables(
      :backend_name_line => backend_name,
      :stats_uri_line => stats_uri,
      :stats_auth_line => stats_auth,
      :health_uri_line => health_uri,
      :health_check_line => health_chk
    )
  end

  # (Re)generate the haproxy config file.
  execute "/opt/mkhoj/conf/lb/haproxy-genconf.pl" do
    command "perl /opt/mkhoj/conf/lb/haproxy-genconf.pl"
    user "haproxy"
    group "haproxy"
    umask 0077
    action :run
    notifies :restart, resources(:service => "haproxy")
  end

  # Tag this server as a load balancer for vhost it will answer for so app servers can send requests to it.
  right_link_tag "loadbalancer:#{vhost_name}=lb"

end # action :add_vhost do

action :attach do

  vhost_name = new_resource.vhost_name

  log "  Attaching #{new_resource.backend_id} / #{new_resource.backend_ip} / #{vhost_name}"

  # Create haproxy service.
  service "haproxy" do
    supports :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

  # (Re)generate the haproxy config file.
  execute "/opt/mkhoj/conf/lb/haproxy-genconf.pl" do
    command "perl /opt/mkhoj/conf/lb/haproxy-genconf.pl"
    user "haproxy"
    group "haproxy"
    umask 0077
    action :nothing
    notifies :restart, resources(:service => "haproxy")
  end

  # Create an individual server file for each vhost and notify the concatenation script if necessary.
  template ::File.join("/opt/mkhoj/conf/lb/lb_haproxy.d", vhost_name, new_resource.backend_id) do
    source "haproxy_server.erb"
    owner "haproxy"
    group "haproxy"
    mode 0600
    backup false
    variables(
      :backend_name => new_resource.backend_id,
      :backend_ip => new_resource.backend_ip,
      :max_conn_per_server => node[:app_inmobi_lb][:max_conn_per_server],
      :health_check_uri => node[:app_inmobi_lb][:health_check_uri]
    )
    notifies :run, resources(:execute => "/opt/mkhoj/conf/lb/haproxy-genconf.pl")
  end

end # action :attach do

action :attach_request do

  vhost_name = new_resource.vhost_name

  log "  Attach request for #{new_resource.backend_id} / #{new_resource.backend_ip} / #{vhost_name}"

  # Run remote_recipe for each vhost app server wants to be part of.
  remote_recipe "Attach me to load balancer" do
    recipe "app_inmobi_lb::handle_attach"
    attributes :remote_recipe => {
      :backend_ip => new_resource.backend_ip,
      :backend_id => new_resource.backend_id,
      :vhost_names => vhost_name
    }
    recipients_tags "loadbalancer:#{vhost_name}=lb"
  end

end # action :attach_request do

action :detach do

  vhost_name = new_resource.vhost_name

  log "  Detaching #{new_resource.backend_id} from #{vhost_name}"

  # Create haproxy service.
  service "haproxy" do
    supports :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

  # (Re)generate the haproxy config file.
  execute "/opt/mkhoj/conf/lb/haproxy-genconf.pl" do
    command "perl /opt/mkhoj/conf/lb/haproxy-genconf.pl"
    user "haproxy"
    group "haproxy"
    umask 0077
    action :nothing
    notifies :restart, resources(:service => "haproxy")
  end

  # Delete the individual server file and notify the concatenation script if necessary.
  file ::File.join("/opt/mkhoj/conf/lb/lb_haproxy.d", vhost_name, new_resource.backend_id) do
    action :delete
    backup false
    notifies :run, resources(:execute => "/opt/mkhoj/conf/lb/haproxy-genconf.pl")
  end

end # action :detach do

action :detach_request do

  vhost_name = new_resource.vhost_name

  log "  Detach request for #{new_resource.backend_id} / #{vhost_name}"

  # Run remote_recipe for each vhost app server is part of.
  remote_recipe "Detach me from load balancer" do
    recipe "app_inmobi_lb::handle_detach"
    attributes :remote_recipe => {
      :backend_id => new_resource.backend_id,
      :vhost_names => vhost_name
    }
    recipients_tags "loadbalancer:#{vhost_name}=lb"
  end

end # action :detach_request do

action :setup_monitoring do

  log "  Setup monitoring for haproxy"

  # Install the haproxy collectd script into the collectd library plugins directory.
  remote_file(::File.join(node[:rightscale][:collectd_lib], "plugins", "haproxy")) do
    source "haproxy1.4.rb"
    mode "0755"
  end

  # Add a collectd config file for the haproxy collectd script with the exec plugin and restart collectd if necessary.
  template ::File.join(node[:rightscale][:collectd_plugin_dir], "haproxy.conf") do
    backup false
    source "haproxy_collectd_exec.erb"
    notifies :restart, resources(:service => "collectd")
  end

  ruby_block "add_collectd_gauges" do
    block do
      types_file = ::File.join(node[:rightscale][:collectd_share], "types.db")
      typesdb = IO.read(types_file)
      unless typesdb.include?("gague-age") && typesdb.include?("haproxy_sessions")
        typesdb += "\nhaproxy_sessions        current_queued:GAUGE:0:65535, current_session:GAUGE:0:65535\nhaproxy_traffic         cumulative_requests:COUNTER:0:200000000, response_errors:COUNTER:0:200000000, health_check_errors:COUNTER:0:200000000\nhaproxy_status          status:GAUGE:-255:255\n"
        ::File.open(types_file, "w") { |f| f.write(typesdb) }
      end
    end
  end

end # action :setup_monitoring do

action :restart do

  log "  Restarting haproxy"

  require 'timeout'

  Timeout::timeout(new_resource.timeout) do
    while true
      `service #{new_resource.name} stop`

      break if `service #{new_resource.name} status` !~ /is running/
      Chef::Log.info "service #{new_resource.name} not stopped; retrying in 5 seconds"
      sleep 5
    end

    while true
      `service #{new_resource.name} start`

      break if `service #{new_resource.name} status` =~ /is running/
      Chef::Log.info "service #{new_resource.name} not started; retrying in 5 seconds"
      sleep 5
    end
  end

end # action :restart do
