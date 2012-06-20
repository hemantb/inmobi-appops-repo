rightscale_marker :begin

  class Chef::Recipe
    include Inmobi::Redis::Helper
  end

  #setup redis server
  app_inmobi_redis "install_redis_server" do
    action :install
  end

  include_recipe "rightscale::setup_server_tags"
  include_recipe "rightscale::setup_monitoring"

  #Setup Tags
  right_link_tag "appserver:active=true"
  right_link_tag "appserver:listen_ip=#{node[:app][:ip]}"
  right_link_tag "redis:listen_ip=#{node[:app][:ip]}"
  right_link_tag "redis:listen_port=#{node[:app_inmobi_redis][:redis_port]}"
  right_link_tag "redis:#{node[:app_inmobi_redis][:app_name]}=#{node[:app_inmobi_redis][:role]}"

  node[:app_inmobi_redis][:installed] = "true"

rightscale_marker :end
