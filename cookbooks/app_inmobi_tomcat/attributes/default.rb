#
# Cookbook Name:: app_inmobi_tomcat
#
# Copyright Inmobi, Inc. All rights reserved.
# Author: Bhagyaraj.g

# Recommended attributes

# This is a set instead of set_unless to support start/stop when the IP changes.
set[:app][:ip] = node[:cloud][:private_ips][0]

set_unless[:app_inmobi_tomcat][:webapp][:vhosts] = nil
# Defines the maximum value of the permanent generation space size
set_unless[:app_inmobi_tomcat][:java][:maxpermsize] = "256m"
# Defines the maximum size of the heap used by the JVM
set_unless[:app_inmobi_tomcat][:java][:xmx] = "512m"
set_unless[:app_inmobi_tomcat][:java][:heapdumppath] = "/var/log/tomcat6/dump.tmp"
set_unless[:app_inmobi_tomcat][:java][:jmxport] = "9004"
set_unless[:app_inmobi_tomcat][:java][:extraopts] = "-XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -XX:+CMSIncrementalPacing -XX:CMSIncrementalDutyCycleMin=0"
set_unless[:app_inmobi_tomcat][:port] = "8080"
set_unless[:app_inmobi_tomcat][:base] = "webapps"

# Calculated attributes
# Defining java alternatives, tomcat user and group parameters depending on platform.
case node[:platform]
when "ubuntu", "debian"
  set[:app_inmobi_tomcat][:app_user] = "tomcat6"
  set[:app_inmobi_tomcat][:app_group] = "tomcat6"
  set[:app_inmobi_tomcat][:alternatives_cmd] = "update-alternatives --set java /usr/lib/jvm/java-6-sun/jre/bin/java"
when "centos", "fedora", "suse", "redhat", "redhatenterpriseserver"
  set[:app_inmobi_tomcat][:app_user] = "tomcat"
  set[:app_inmobi_tomcat][:app_group] = "tomcat"
  set[:app_inmobi_tomcat][:alternatives_cmd] = "alternatives --auto java"
else
  raise "Unrecognized distro #{node[:platform]}, exiting "
end

set_unless[:app_inmobi_tomcat][:app_user] = "tomcat6"
set_unless[:app_inmobi_tomcat][:app_group] = "tomcat6"
set_unless[:app_inmobi_tomcat][:webapp][:restart] = "true"
