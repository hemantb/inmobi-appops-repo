#
# Cookbook Name:: app
# Resource:: app::default
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.


# Install packages required for application server setup
actions :install
  # Set of installed packages
  attribute :packages, :kind_of => Array

# Set up the application vhost on specified port
# Action designed to setup APP LWRP with common parameters required for apache vhost file
actions :setup_vhost
  # Application root
  attribute :root, :kind_of => String
  # Application port
  attribute :port, :kind_of => Integer


# Runs application server start sequence
actions :start

# Runs application server stop sequence
actions :stop

# Runs application server restart sequence
actions :restart
