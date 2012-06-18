maintainer       "Inmobi, Inc."
maintainer_email "bhagyaraj.g@inmobi.com"
license          "Copyright Inmobi, Inc. All rights reserved."
description      "Inmobi HAProxy LB Manager"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "1.0.0"

depends "rightscale"

recipe "app_inmobi_lb::default", "This loads the required load balancer resources."
recipe "app_inmobi_lb::setup_load_balancer", "Installs the load balancer and adds the loadbalancer:<vhost_name>=lb tags to your server, which identifies it as a load balancer for a given listener pool. This tag is used by application servers to request connection/disconnection."
recipe "app_inmobi_lb::handle_attach", "Remote recipe executed by do_attach_request. DO NOT RUN."
recipe "app_inmobi_lb::handle_detach", "Remote recipe executed by do_detach_request. DO NOT RUN."
recipe "app_inmobi_lb::do_attach_all", "Registers all running application servers with the loadbalancer:<vhost_name>=app tags. This should be run on a load balancer to connect all application servers in deployment."
recipe "app_inmobi_lb::do_attach_request", "Sends request to all servers with loadbalancer:<vhost_name>=lb tag to attach current server to listener pool. This should be run by a new application server that is ready to accept connections."
recipe "app_inmobi_lb::do_detach_request", "Sends request to all servers with loadbalancer:<vhost_name>=lb tag to detach current server from listener pool. This should be run by an application server at decommission."
recipe "app_inmobi_lb::setup_monitoring", "Installs the load balancer collectd plugin for monitoring support."

attribute "app_inmobi_lb/vhost_names",
  :display_name => "Virtual Host Names on the load balancer",
  :description => "Comma-separated list of host names in the format (sticky/nosticy)-sourceport-virtualhostname-destinationport for which the load balancer will answer website requests.", 
  :required => true,
  :recipes => [
    "app_inmobi_lb::default",
    "app_inmobi_lb::handle_attach",
    "app_inmobi_lb::handle_detach",
    "app_inmobi_lb::setup_load_balancer",
    "app_inmobi_lb::do_attach_all"
  ]

attribute "app_inmobi_lb/real_vhost_names",
  :display_name => "Virtual Host Names on the Real server",
  :description => "Comma-separated list of host names in the format (sticky/nosticky)-sourceport-virtualhostname-destinationport for which the load balancer will answer website requests.", 
  :required => true,
  :recipes => [
    "app_inmobi_lb::do_attach_request",
    "app_inmobi_lb::do_detach_request",
  ]

attribute "app_inmobi_lb/stats_uri",
  :display_name => "Status URI",
  :description => "The URI for the load balancer statistics report page (e.g., /haproxy-status). This page lists the current session, queued session, response error, health check error, server status, etc. for each load balancer group.",
  :required => "optional",
  :default => "/haproxy-status",
  :recipes => [
    "app_inmobi_lb::setup_load_balancer"
  ]

attribute "app_inmobi_lb/stats_user",
  :display_name => "Status Page Username",
  :description => "The username that is required to access the load balancer statistics report page.",
  :required => "optional",
  :default => "",
  :recipes => [
    "app_inmobi_lb::setup_load_balancer"
  ]

attribute "app_inmobi_lb/stats_password",
  :display_name => "Status Page Password",
  :description => "The password that is required to access the load balancer statistics report page.",
  :required => "optional",
  :default => "",
  :recipes => [
    "app_inmobi_lb::setup_load_balancer"
  ]

attribute "app_inmobi_lb/session_stickiness",
  :display_name => "Use Session Stickiness",
  :description => "Determines session stickiness. Set to 'True' to use session stickiness, where the load balancer will reconnect a session to the last server it was connected to (via a cookie). Set to 'False' if you do not want to use sticky sessions; the load balancer will establish a connection with the next available server.",
  :required => "optional",
  :choice => ["true", "false"],
  :default => "true",
  :recipes => [
    "app_inmobi_lb::handle_attach"
  ]

attribute "app_inmobi_lb/health_check_uri",
  :display_name => "Health Check URI",
  :description => "The URI that the load balancer will use to check the health of a server. It is only used for HTTP (not HTTPS) requests.",
  :required => "optional",
  :default => "/lbstatus.html",
  :recipes => [
    "app_inmobi_lb::setup_load_balancer",
    "app_inmobi_lb::handle_attach"
  ]

attribute "app_inmobi_lb/service/provider",
  :display_name => "Load Balance Provider",
  :description => "Specify the load balance provider to use: either 'lb_haproxy' for HAProxy, 'lb_elb' for AWS Load Balancing, or 'lb_clb' for Rackspace Cloud Load Balancing.",
  :required => "recommended",
  :default => "app_inmobi_lb",
  :choice => ["app_inmobi_lb"],
  :recipes => [
    "app_inmobi_lb::default",
    "app_inmobi_lb::do_attach_request",
    "app_inmobi_lb::do_detach_request"
  ]
