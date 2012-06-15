#
# Cookbook Name:: app_inmobi_tomcat
#
# Copyright Inmobi, Inc. All rights reserved.
# Author: Bhagyaraj.g

# Install packages required for application server setup
actions :install
  # Set of installed packages
  attribute :packages, :kind_of => Array

# Set up the application vhost on specified port
# Action designed to setup APP LWRP with common parameters required for apache vhost file
actions :setup_config

actions :bhagya

#  # Application root
#  attribute :root, :kind_of => String
#  # Application port
  attribute :port, :kind_of => Integer


# Runs application server start sequence
actions :start

# Runs application server stop sequence
actions :stop

# Runs application server restart sequence
actions :restart

# Action designed to setup APP LWRP with common parameters required for install and configuration of required monitoring software
actions :setup_monitoring
