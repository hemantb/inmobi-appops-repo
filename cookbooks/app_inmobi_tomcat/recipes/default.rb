#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

log "  Setting provider specific settings for tomcat"

# Preparing list of database adapter packages depending on platform and database adapter
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
