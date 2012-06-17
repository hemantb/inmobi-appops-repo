rightscale_marker :begin

execute "update apt cache" do
  command "apt-get update"
  ignore_failure true
end

script :wq

service "#{node[:app_inmobi_redis][:service]}" do
  start_command "#{node[:app_inmobi_redis][:startcmd]}"
  stop_command "#{node[:app_inmobi_redis][:stopcmd]}"
  action :nothing
end

node[:app_inmobi_tomcat][:webapp][:debians] .each do |p|
  log "Installing #{p}"
  if p =~ /^([^=]+)=(.+)$/
     package $1 do
        version $2
        options "--force-yes"
        notifies :restart , resources(:service => "#{node[:app_inmobi_redis][:service]}") unless node[:app_inmobi_redis][:restart] == "false"
     end
   elsif node[:app_inmobi_tomcat][:webapp][:latest] == "true"
     package p do
        options "--force-yes"
        notifies :restart , resources(:service => "#{node[:app_inmobi_redis][:service]}") unless node[:app_inmobi_redis][:restart] == "false"
     end
   else
     raise "#{p} doesn't match the pattern packagename=version format. please fix or set latest? variable to true"
   end
end

right_link_tag "appserver:active=true"
right_link_tag "appserver:listen_ip=#{node[:app][:ip]}"

rightscale_marker :end
