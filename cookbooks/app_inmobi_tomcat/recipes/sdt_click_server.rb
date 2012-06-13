#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

log "  Installing sdt click server package"

# Preparing list of database adapter packages depending on platform and database adapter
node[:app_tomcat][:packages] = [
      "psql"
]

app_inmobi_tomcat "install_packages" do
  persist true
  packages node[:app_tomcat][:packages]
  action :install
end

action_restart

rs_utils_marker :end
