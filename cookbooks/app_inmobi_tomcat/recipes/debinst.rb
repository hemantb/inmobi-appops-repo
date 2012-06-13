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

rs_utils_marker :end
