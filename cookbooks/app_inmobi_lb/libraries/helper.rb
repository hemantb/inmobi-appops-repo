#
# Cookbook Name:: inmobi_lb
#

module Inmobi
  module LB
    module Helper

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
        require "timeout"
        app_servers = Hash.new
        main_tags = ["loadbalancer:#{vhost_name}=app"]
        secondary_tags = ["server:uuid=*", "appserver:listen_ip=*"]

        r = server_collection "app_servers" do
          tags main_tags
          action :nothing
        end

     begin
     Timeout::timeout(60) do
      all_tags = main_tags.collect
      all_tags += secondary_tags.collect if secondary_tags
      delay = 1

      while true
        r.run_action(:load)
        collection = node[:server_collection]["app_servers"]

        break if collection.empty?
        break if !collection.empty? && collection.all? do |id, tags|
          all_tags.all? do |prefix|
            tags.detect { |tag| RightScale::Utils::Helper.matches_tag_wildcard?(prefix, tag) }
          end
        end

        delay = ((delay == 1) ? 2 : (delay*delay)) 
        Chef::Log.info "not all tags for loadbalancer:#{vhost_name}=app exist; retrying in #{delay} seconds..."
        sleep delay
     end
    end
    rescue Timeout::Error => e
      raise "ERROR: timed out trying to find servers tagged with loadbalancer:#{vhost_name}=app"
    end

        node[:server_collection]['app_servers'].to_hash.values.each do |tags|
          uuid = RightScale::Utils::Helper.get_tag_value('server:uuid', tags)
          ip = RightScale::Utils::Helper.get_tag_value('appserver:listen_ip', tags)
          app_servers[uuid] = {}
          app_servers[uuid][:ip] = ip
        end

        app_servers
      end # def query_appservers(vhost_name)

    end
  end

  # Set provider for each vhost.
  def vhosts(vhost_list)
    vhost = vhost_list.gsub(/\s+/, "")
    if vhost !~ /^(sticky|nosticky)-(\d+)-(.+)-(\d+)$/  
      raise "#{vhost} is not in valid format"
    end
    return vhost.split(",").uniq.each
  end

end
