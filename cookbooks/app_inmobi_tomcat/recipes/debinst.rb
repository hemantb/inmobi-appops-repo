rs_utils_marker :begin

node[:app_tomcat][:webapp][:debians] .each do |p|
  log "Installing #{p}"
  package p
end

case node[:app_tomcat][:webapp][:restart]
when "true"
  app_inmobi_tomcat "default" do
    action :restart
  end
end

if node[:app_tomcat][:webapp][:vhosts] do
  node[:app_tomcat][:webapp][:vhosts] .each do |vhost_name|
    log "Adding tag for loadbalancer:#{vhost_name}=app"
    right_link_tag "loadbalancer:#{vhost_name}=app"
  end
end

rs_utils_marker :end
