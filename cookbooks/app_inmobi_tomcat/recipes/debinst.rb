rightscale_marker :begin

include_recipe "app_inmobi_tomcat::default"

log "debians #{node[:app_inmobi_tomcat][:webapp][:debians]}"

node[:app_inmobi_tomcat][:webapp][:debians] .each do |p|
  log "Installing #{p}"
  if p =~ /^([^=]+)=(.+)$/
     package $1 do
        version $2
        options "--force-yes"
     end
   elsif node[:app_inmobi_tomcat][:webapp][:latest] == "true"
     package p do
       options "--force-yes"
     end
   else
     raise "#{p} doesn't match the pattern packagename=version format. please fix or set latest? variable to true"
   end
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
