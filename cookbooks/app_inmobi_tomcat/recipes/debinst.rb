rightscale_marker :begin

node[:app_inmobi_tomcat][:webapp][:debians] .each do |p|
  log "Installing #{p}"
  package p
end

case node[:app_inmobi_tomcat][:webapp][:restart]
when "true"
  app_inmobi_tomcat "default" do
    action :restart
  end
end

if node[:app_inmobi_tomcat][:webapp][:vhosts] do
  node[:app_inmobi_tomcat][:webapp][:vhosts] .each do |vhost_name|
    log "Adding tag for loadbalancer:#{vhost_name}=app"
    right_link_tag "loadbalancer:#{vhost_name}=app"
  end
end

right_link_tag "appserver:active=true"
right_link_tag "appserver:listen_ip=#{node[:inmobi_app_tomcat][:ip]}"
right_link_tag "appserver:listen_port=#{node[:inmobi_app_tomcat][:port]}"

rightscale_marker :end
