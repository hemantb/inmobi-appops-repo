        main_tags = ["loadbalancer:rs1.app.ev1.inmobi.com=app"]
        secondary_tags = ["server:uuid=*", "appserver:listen_ip=*", "appserver:listen_port=*"]

        r = server_collection 'app_servers' do
          tags main_tags
          action :nothing
        end

        r.run_action(:load)

	log "Printing tags"
        node[:server_collection]["app_servers"].to_hash.values.each do |tags|
		log "this is the tag #{tags}"
	end

	log "done printing tags"
=begin
     begin
     Timeout::timeout(60) do
      all_tags = main_tags.collect
      all_tags += secondary_tags.collect if secondary_tags
      delay = 1

      while true
        r.run_action(:load)
        collection = node[:server_collection]["app_servers"]

        break if collection.empty?
	log "I am here checking..."
        break if !collection.empty? && collection.all? do |id, tags|
            log "atlease I am here"
          all_tags.all? do |prefix|
            log "checking for #{prefix} and tags as #{tags.inspect} for id #{id}"
            tags.detect { |tag| RightScale::Utils::Helper.matches_tag_wildcard?(prefix, tag) }
          end
        end

        log "No man"
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
