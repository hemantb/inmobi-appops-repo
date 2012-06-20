#
# Cookbook Name:: app_inmobi_redis
#

module Inmobi
  module Redis
    module Helper

      def get_redis_masters(app_name)
        require "timeout"
        redis_servers = Hash.new
        main_tags = ["redis:#{app_name}=master"]
        secondary_tags = ["server:uuid=*", "redis:listen_ip=*", "redis:port=*"]

        r = server_collection "redis_servers" do
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
            collection = node[:server_collection]["redis_servers"]

            break if collection.empty?
            break if !collection.empty? && collection.all? do |id, tags|
              all_tags.all? do |prefix|
                tags.detect { |tag| RightScale::Utils::Helper.matches_tag_wildcard?(prefix, tag) }
              end
            end

            delay = ((delay == 1) ? 2 : (delay*delay)) 
            Chef::Log.info "not all tags for redis:#{app_name}=master exist; retrying in #{delay} seconds..."
            sleep delay
          end
        end
        rescue Timeout::Error => e
          raise "ERROR: timed out trying to find servers tagged with redis:#{app_name}=master"
        end

        node[:server_collection]['redis_servers'].to_hash.values.each do |tags|
          uuid = RightScale::Utils::Helper.get_tag_value('server:uuid', tags)
          ip = RightScale::Utils::Helper.get_tag_value('redis:listen_ip', tags)
          port = RightScale::Utils::Helper.get_tag_value('redis:listen_port', tags)
          redis_servers[uuid] = {}
          redis_servers[uuid][:ip] = ip
          redis_servers[uuid][:port] = port
        end

        redis_servers
      end

    end
  end
end
