#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Setting provider specific settings for tomcat"
node[:app][:provider] = "app_adroit"

# Preparing list of database adapter packages depending on platform and database adapter
case node[:platform]
when "ubuntu", "debian"
  case node[:app_adroit][:function]
  when "backend"
    node[:app][:packages] = [
      "roi-feedback-package"
      #"java-gcj-compat-dev",
    ]
  when "frontend"
    node[:app][:packages] = [
      #"java-gcj-compat-dev",
    ]
  when "gboconsole"
    node[:app][:packages] = [
      #"java-gcj-compat-dev",
    ]
  else
    raise "Unrecognized database adapter #{node[:app_tomcat][:db_adapter]}, exiting "
  end
else
  raise "Unrecognized distro #{node[:platform]}, exiting "
end

# Setting app LWRP attribute
#node[:app][:root] = "#{node[:repo][:default][:destination]}/#{node[:web_apache][:application_name]}"
# tomcat shares the same doc root with the application destination
#node[:app][:destination]="#{node[:app][:root]}"

#directory "#{node[:app][:destination]}" do
#  recursive true
#end

rightscale_marker :end
