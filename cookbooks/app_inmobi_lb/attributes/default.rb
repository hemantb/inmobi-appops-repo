# 
# Cookbook Name:: lb
#

# Required attributes that determine which provider to use.
set[:app][:ip] = node[:cloud][:private_ips][0]

set_unless[:app_inmobi_lb][:service][:provider] = "app_inmobi_lb"

# Logical name for the application (balancing group) to use.
set_unless[:app_inmobi_lb][:host]= nil
set_unless[:server_collection]['app_servers'] = Hash.new

# The address that load balancer should bind to.
set_unless[:app_inmobi_lb][:bind_address] = "0.0.0.0"
# Port that load balancer should bind to.
set_unless[:app_inmobi_lb][:bind_port] = 85

# URI for the load balancer to use to check the health of a server (only used when using http templates).
set_unless[:app_inmobi_lb][:health_check_uri] = "/"
# URI that the load balancer uses to publish its status.
set_unless[:app_inmobi_lb][:stats_uri] = ""
# Username required to access to the haproxy stats page.
set_unless[:app_inmobi_lb][:stats_user] = ""
# Password required to access to the haproxy stats page.
set_unless[:app_inmobi_lb][:stats_password] = ""
set_unless[:app_inmobi_lb][:vhost_port] = ""
set_unless[:app_inmobi_lb][:session_stickiness] = ""
set_unless[:app_inmobi_lb][:max_conn_per_server] = "500"
# Reconverge cron times. Set the minute to a random number so reconverges are spread out.
set_unless[:app_inmobi_lb][:cron_reconverge_hour] = "*"
set_unless[:app_inmobi_lb][:cron_reconverge_minute] = "#{5+rand(50)}"

# Stores the list of appplication servers being loadbalanced.
set_unless[:app_inmobi_lb][:appserver_list] = {}

# Config file used by load balancer.
set_unless[:app_inmobi_lb][:cfg_file] = "/opt/mkhoj/conf/lb/inmobi_lb.cfg"

# Web service name based on OS.
case platform
when "redhat", "centos", "fedora", "suse"
  set_unless[:app_inmobi_lb][:apache_name] = "httpd"
else
  set_unless[:app_inmobi_lb][:apache_name] = "apache2"
end
