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

right_link_tag "appserver:active=true"
right_link_tag "appserver:listen_ip=#{node[:app][:ip]}"

rightscale_marker :end
