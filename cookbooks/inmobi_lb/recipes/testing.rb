rightscale_marker :begin

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

rightscale_marker :end
