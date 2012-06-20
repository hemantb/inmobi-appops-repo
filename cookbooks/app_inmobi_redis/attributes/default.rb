set[:app][:ip] = node[:cloud][:private_ips][0]
set[:app_inmobi_redis][:service][:provider] = "app_inmobi_redis"

set_unless[:app_inmobi_redis][:role] = nil
set_unless[:app_inmobi_redis][:app_name] = nil
set_unless[:app_inmobi_redis][:redis_port] = "6379"
set_unless[:app_inmobi_redis][:bind_address] = "0.0.0.0"
set_unless[:app_inmobi_redis][:client_timeout] = "300"
set_unless[:app_inmobi_redis][:db_num] = "16"
set_unless[:app_inmobi_redis][:bgsave_line] = ""
set_unless[:app_inmobi_redis][:dump_file] = "dump.rdb"
set_unless[:app_inmobi_redis][:data_dir] = "/var/lib"
set_unless[:app_inmobi_redis][:slave_of_line] = ""
set_unless[:app_inmobi_redis][:max_clients] = "500"
set_unless[:app_inmobi_redis][:append_only] = "yes"
set_unless[:app_inmobi_redis][:append_fsync] = "everysec"
set_unless[:app_inmobi_redis][:auto_aof_rewrite_percentage] = "0"
set_unless[:app_inmobi_redis][:slowlog_log_slower_than] = "10000"
