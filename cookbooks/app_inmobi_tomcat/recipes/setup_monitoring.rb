# Rebuild the collectd configuration file if necessary.

rightscale_marker :begin

include_recipe "rightscale::setup_monitoring"

app_inmobi_tomcat "default" do
  action :setup_monitoring
end

rightscale_marker :end
