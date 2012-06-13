#
# Cookbook Name:: rs_tools
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

SANDBOX_BIN_DIR = "/opt/rightscale/sandbox/bin"
RS_TOOL_VERSION = "1.0.37"
RACKSPACE_GEM = ::File.join(::File.dirname(__FILE__), "..", "files", "default", "right_rackspace-0.0.0.20111110.gem")
RS_TOOL_GEM = ::File.join(::File.dirname(__FILE__), "..", "files", "default", "rightscale_tools-#{RS_TOOL_VERSION}.gem")
RIGHT_AWS_GEM = ::File.join(::File.dirname(__FILE__), "..", "files", "default", 'right_aws-2.1.1.gem')

# Install tools dependencies
#

# right_aws
r = gem_package RIGHT_AWS_GEM do
  gem_binary "#{SANDBOX_BIN_DIR}/gem"
  version '2.1.1'
  action :nothing
end
r.run_action(:install)

# right_rackspace
r = gem_package RACKSPACE_GEM do
  gem_binary "#{SANDBOX_BIN_DIR}/gem"
  version "0.0.0"
  action :nothing
end
r.run_action(:install)

# Install tools
#
r = gem_package RS_TOOL_GEM do
  gem_binary "#{SANDBOX_BIN_DIR}/gem"
  version RS_TOOL_VERSION
  action :nothing
end
r.run_action(:install)

Gem.clear_paths

rs_utils_marker :end
