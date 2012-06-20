class Inmobi
  class Redis
    class Helper
      def get_redis_master(appname)
        require "timeout"
        redi_servers = Hash.new
        main_tags = ["redis:#{app_name}=master"]
        secondary_tags = ["server:uuid=*", "appserver:listen_ip=*"]

        r = server_collection "redis_master" do
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
            collection = node[:server_collection]["redis_master"]

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
          raise "ERROR: timed out trying to find servers tagged with redis:#{appname}=master"
        end

        if node[:server_collection]['redis_master'].length > 1
         throw "More than 1 redis servers found for this app #{node[:app_inmobi_lb][:redis_app]}"
        end

        node[:server_collection]['redis_master'].to_hash.values.first do |tags|
          uuid = RightScale::Utils::Helper.get_tag_value('server:uuid', tags)
          ip = RightScale::Utils::Helper.get_tag_value('appserver:listen_ip', tags)
          redis_servers[uuid] = {}
          redis_servers[uuid][:ip] = ip
        end

        redis_servers
     end
    end
  end
end
