#
# Cookbook Name:: app_inmobi_tomcat
#
# Copyright Inmobi, Inc. All rights reserved.
# Author: Bhagyaraj.g

rs_utils_marker :begin

log "  Setting provider specific settings for tomcat"

case node[:platform]
when "ubuntu", "debian"
    node[:app_tomcat][:packages] = [
      "mkhoj-base",
      "tomcat6",
      "tomcat6-common",
      "jsvc",
      "sun-java6-jre"
    ]
when "centos", "fedora", "suse", "redhat", "redhatenterpriseserver"
    node[:app_tomcat][:packages] = [
      "eclipse-ecj",
      "tomcat6",
      "tomcat6-admin-webapps",
      "tomcat6-webapps",
      "tomcat-native"
    ]
end

app_inmobi_tomcat "install_packages" do
  persist true
  packages node[:app_tomcat][:packages]
  action :install
end

app_inmobi_tomcat "setup_configuration" do
  persist true
  action :setup_config
end

rs_utils_marker :end
