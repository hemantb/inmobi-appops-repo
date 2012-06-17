#
# Cookbook Name:: app_inmobi_tomcat
#
# Copyright Inmobi, Inc. All rights reserved.
# Author: Bhagyaraj.g

action :restart do

rightscale_marker :begin

  log "Running restart sequence of #{new_resource.name}"

  if node[:app_inmobi_debinst][:start] != nil && node[:app_inmobi_debinst][:stop] != nil
    log "start command = #{node[:app_inmobi_debinst][:startcmd]}"
    log "stop command = #{node[:app_inmobi_debinst][:stopcmd]}"

    log "Stopping #{node[:app_inmobi_debinst][:service]} service"
    service "#{node[:app_inmobi_debinst][:service]}" do
      start_command "#{node[:app_inmobi_debinst][:stopcmd]}"
      action :stop
    end

    sleep 10

    log "Starting #{node[:app_inmobi_debinst][:service]} service"
    service "#{node[:app_inmobi_debinst][:service]}" do
      stop_command "#{node[:app_inmobi_debinst][:startcmd]}"
      action :start
    end

  elsif node[:app_inmobi_debinst][:start] != nil || node[:app_inmobi_debinst][:stop] != nil
    log "start command = #{node[:app_inmobi_debinst][:startcmd]}"
    log "stop command = #{node[:app_inmobi_debinst][:stopcmd]}"
    raise "either start/stop command is missing, both should exist of both should not exist"

  else

    log "Stopping /etc/init.d/#{node[:app_inmobi_debinst][:service]}"
    service "#{node[:app_inmobi_debinst][:service]}" do
      action :stop
    end

    sleep 10

    log "Starting /etc/init.d/#{node[:app_inmobi_debinst][:service]}"
    service "#{node[:app_inmobi_debinst][:service]}" do
      action :start
    end

  end

rightscale_marker :end

end
