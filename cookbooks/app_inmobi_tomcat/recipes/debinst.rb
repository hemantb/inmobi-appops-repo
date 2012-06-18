rightscale_marker :begin

include_recipe "app_inmobi_tomcat::default"

log "debians #{node[:app_inmobi_tomcat][:webapp][:debians]}"
log "restart #{node[:app_inmobi_tomcat][:webapp][:restart]}"

service "tomcat6" do
  action :nothing
end

debians = node[:app_inmobi_tomcat][:webapp][:debians]
debians.gsub(/\s+/, "").split(",").uniq.each do |p|
  log "Installing #{p}"
  if p =~ /^([^=]+)=(.+)$/
     package $1 do
        version $2
        options "--force-yes"
        notifies :restart , resources(:service => "tomcat6") unless node[:app_inmobi_tomcat][:webapp][:restart] == "false"
     end
   elsif node[:app_inmobi_tomcat][:webapp][:latest] == "true"
     package p do
        options "--force-yes"
        notifies :restart , resources(:service => "tomcat6") unless node[:app_inmobi_tomcat][:webapp][:restart] == "false"
     end
   else
     raise "#{p} doesn't match the pattern packagename=version format. please fix or set latest? variable to true"
   end
end

right_link_tag "appserver:active=true"
right_link_tag "appserver:listen_ip=#{node[:app][:ip]}"

rightscale_marker :end
