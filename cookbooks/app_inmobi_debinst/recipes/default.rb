rightscale_marker :begin

log "restart = #{node[:app_inmobi_debinst][:restart]}"
log "start = #{node[:app_inmobi_debinst][:startcmd]}"
log "stop = #{node[:app_inmobi_debinst][:stopcmd]}"
log "service = #{node[:app_inmobi_debinst][:service]}"
log "latest = #{node[:app_inmobi_debinst][:latest]}"

execute "update apt cache" do
  command "apt-get update"
  ignore_failure true
end

if node[:app_inmobi_debinst][:stopcmd] == nil || node[:app_inmobi_debinst][:startcmd] == nil
   node[:app_inmobi_debinst][:startcmd] = "/etc/init.d/#{node[:app_inmobi_debinst][:service]} start"
   node[:app_inmobi_debinst][:stopcmd] = "/etc/init.d/#{node[:app_inmobi_debinst][:service]} stop"
end

service "#{node[:app_inmobi_debinst][:service]}" do
  start_command "#{node[:app_inmobi_debinst][:startcmd]}"
  stop_command "#{node[:app_inmobi_debinst][:stopcmd]}"
  action :nothing
end

node[:app_inmobi_tomcat][:webapp][:debians] .each do |p|
  log "Installing #{p}"
  if p =~ /^([^=]+)=(.+)$/
     package $1 do
        version $2
        options "--force-yes"
        notifies :restart , resources(:service => "#{node[:app_inmobi_debinst][:service]}") unless node[:app_inmobi_debinst][:restart] == "false"
     end
   elsif node[:app_inmobi_tomcat][:webapp][:latest] == "true"
     package p do
        options "--force-yes"
        notifies :restart , resources(:service => "#{node[:app_inmobi_debinst][:service]}") unless node[:app_inmobi_debinst][:restart] == "false"
     end
   else
     raise "#{p} doesn't match the pattern packagename=version format. please fix or set latest? variable to true"
   end
end

right_link_tag "appserver:active=true"
right_link_tag "appserver:listen_ip=#{node[:app][:ip]}"

rightscale_marker :end
