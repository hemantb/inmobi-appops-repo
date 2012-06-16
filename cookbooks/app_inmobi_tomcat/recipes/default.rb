#
# Cookbook Name:: app_inmobi_tomcat
#
# Copyright Inmobi, Inc. All rights reserved.
# Author: Bhagyaraj.g

rightscale_marker :begin

log "  Setting provider specific settings for tomcat"

case node[:platform]
when "ubuntu", "debian"
    node[:app_inmobi_tomcat][:packages] = [
      "mkhoj-base",
      "tomcat6",
      "tomcat6-common",
      "jsvc",
      "sun-java6-jre"
    ]
when "centos", "fedora", "suse", "redhat", "redhatenterpriseserver"
    node[:app_inmobi_tomcat][:packages] = [
      "eclipse-ecj",
      "tomcat6",
      "tomcat6-admin-webapps",
      "tomcat6-webapps",
      "tomcat-native"
    ]
end

app_inmobi_tomcat "install_packages" do
  persist true
  packages node[:app_inmobi_tomcat][:packages]
  action :install
end

app_inmobi_tomcat "setup_configuration" do
  persist true
  action :setup_config
end

app_inmobi_tomcat "setup_monitoring" do
  persist true
  action :setup_monitoring
end


include_recipe "rightscale::setup_timezone"
include_recipe "rightscale::setup_server_tags"

right_link_tag "appserver:active=true"
right_link_tag "appserver:listen_ip=#{node[:app][:ip]}"

rightscale_marker :end
