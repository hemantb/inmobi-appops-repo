#
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module LB
    module Helper

require "timeout"
      # @param [String] vhost_name virtual hosts name.
      #
      # @return [Set] attached_servers set of attached servers for vhost i.e., servers in lb config dir
      #
      def get_attached_servers(vhost_name)
        attached_servers = Set.new
        haproxy_d = "/opt/mkhoj/conf/lb/lb_haproxy.d/#{vhost_name}"
        Dir.entries(haproxy_d).select do |file|
          next if file == "." or file == ".."
          attached_servers.add?(file)
        end if (::File.directory?(haproxy_d))

        attached_servers
      end # def get_attached_servers(vhost_name)

      # @param [String] vhost_name virtual hosts name.
      #
      # @return [Hash] app_servers hash of app servers in deployment answering for vhost_name
      #
      def query_appservers(vhost_name)
        app_servers = Hash.new

        r = server_collection 'app_servers' do
          tags ["loadbalancer:#{vhost_name}=app"]
          action :nothing
        end


  begin
    Timeout::timeout(new_resource.timeout) do
      all_tags =  ["loadbalancer:#{vhost_name}=app", "server:uuid=*", "appserver:listen_ip=*", "appserver:listen_port=*"]
      delay = 1
      while true
        r.run_action(:load)
        collection = node[:server_collection][new_resource.name]

        break if collection.empty?
        break if !collection.empty? && collection.all? do |id, tags|
          all_tags.all? do |prefix|
            tags.detect { |tag| RightScale::Utils::Helper.matches_tag_wildcard?(prefix, tag) }
          end
        end

        delay = RightScale::System::Helper.calculate_exponential_backoff(delay)
        Chef::Log.info "not all tags for #{new_resource.tags.inspect} exist; retrying in #{delay} seconds..."
        sleep delay
      end
    end
  rescue Timeout::Error => e
    raise "ERROR: timed out trying to find servers tagged with #{new_resource.tags.inspect}"
  end

        node[:server_collection]['app_servers'].to_hash.values.each do |tags|
          uuid = RightScale::Utils::Helper.get_tag_value('server:uuid', tags)
          ip = RightScale::Utils::Helper.get_tag_value('appserver:listen_ip', tags)
          port = RightScale::Utils::Helper.get_tag_value('appserver:listen_port', tags)
          app_servers[uuid] = {}
          app_servers[uuid][:ip] = ip
          app_servers[uuid][:backend_port] = port.to_i
        end

        app_servers
      end # def query_appservers(vhost_name)

    end
  end
end
