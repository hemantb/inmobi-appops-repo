#
# Cookbook Name:: app_inmobi_tomcat
#
# Copyright Inmobi, Inc. All rights reserved.
# Author: Bhagyaraj.g

# Recommended attributes

set_unless[:app_tomcat][:webapp][:vhosts] = nil
# Defines the maximum value of the permanent generation space size
set_unless[:app_tomcat][:java][:maxpermsize] = "256m"
# Defines the maximum size of the heap used by the JVM
set_unless[:app_tomcat][:java][:xmx] = "512m"
set_unless[:app_tomcat][:java][:heapdumppath] = "/var/log/tomcat6/dump.tmp"
set_unless[:app_tomcat][:java][:jmxport] = "9004"
set_unless[:app_tomcat][:java][:extraopts] = "-XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -XX:+CMSIncrementalPacing -XX:CMSIncrementalDutyCycleMin=0"
set_unless[:app_tomcat][:port] = "8080"
set_unless[:app_tomcat][:base] = "webapps"

# Calculated attributes
# Defining java alternatives, tomcat user and group parameters depending on platform.
case node[:platform]
when "ubuntu", "debian"
  set[:app_tomcat][:app_user] = "tomcat6"
  set[:app_tomcat][:app_group] = "tomcat6"
  set[:app_tomcat][:alternatives_cmd] = "update-alternatives --set java /usr/lib/jvm/java-6-sun/jre/bin/java"
when "centos", "fedora", "suse", "redhat", "redhatenterpriseserver"
  set[:app_tomcat][:app_user] = "tomcat"
  set[:app_tomcat][:app_group] = "tomcat"
  set[:app_tomcat][:alternatives_cmd] = "alternatives --auto java"
else
  raise "Unrecognized distro #{node[:platform]}, exiting "
end

set_unless[:app_tomcat][:app_user] = "tomcat6"
set_unless[:app_tomcat][:app_group] = "tomcat6"
set_unless[:app_tomcat][:webapp][:restart] = "true"
