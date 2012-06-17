rightscale_marker :begin

log "debians = #{node[:app_inmobi_debinst][:debians]}"
log "service name = #{node[:app_inmobi_debinst][:restart]}"
log "restart required? #{node[:app_inmobi_debinst][:restart]}"
log "start command = #{node[:app_inmobi_debinst][:restart]}"
log "stop command = #{node[:app_inmobi_debinst][:restart]}"

app_inmobi_debinst "app_inmobi_debinst" do
  action :nothing
end

service "app_inmobi_debinst" do
  action :nothing
  not_if {node[:app_inmobi_tomcat][:webapp][:restart] == "false"}
end

node[:app_inmobi_tomcat][:webapp][:debians] .each do |p|
  log "Installing #{p}"
  if p =~ /^([^=]+)=(.+)$/
     package $1 do
        version $2
        options "--force-yes"
        notifies :restart , resources(:service => "tomcat6")
     end
   elsif node[:app_inmobi_tomcat][:webapp][:latest] == "true"
     package p do
        options "--force-yes"
        notifies :restart , resources(:service => "tomcat6")
     end
   else
     raise "#{p} doesn't match the pattern packagename=version format. please fix or set latest? variable to true"
   end
end

right_link_tag "appserver:active=true"
right_link_tag "appserver:listen_ip=#{node[:app][:ip]}"

rightscale_marker :end
