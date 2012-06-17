maintainer       "YOUR_COMPANY_NAME"
maintainer_email "YOUR_EMAIL"
license          "All rights reserved"
description      "Installs/Configures app_inmobi_redis"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

depends "rightscale"

recipe "app_inmobi_redis::default" , "Install redis server 2.4.8"

attribute "app_inmobi_redis/redis_port",
  :display_name => "Redis Port Number",
  :description => "No Description",
  :required => "optional",
  :default => "6379",
  :recipes => [
    "app_inmobi_redis::default",
  ]

attribute "app_inmobi_redis/bind_address",
  :display_name => "Redis Bind address default: 0.0.0.0",
  :description => "No Description",
  :required => "optional",
  :default => "0.0.0.0",
  :recipes => [
    "app_inmobi_redis::default",
  ]

attribute "app_inmobi_redis/client_timeout",
  :display_name => "Close the connection after a client is idle for N seconds (0 to disable) default: 300",
  :description => "No Description",
  :required => "optional",
  :default => "300",
  :recipes => [
    "app_inmobi_redis::default",
  ]

attribute "app_inmobi_redis/db_num",
  :display_name => "Set the number of databases default: 16",
  :description => "No Description",
  :required => "optional",
  :default => "16",
  :recipes => [
    "app_inmobi_redis::default",
  ]

attribute "app_inmobi_redis/bgsave_line",
  :display_name => "mention the config line for auto BGSAVE eg: save 1 1",
  :description => "No Description",
  :required => "optional",
  :recipes => [
    "app_inmobi_redis::default",
  ]

attribute "app_inmobi_redis/dump_file",
  :display_name => "File where BGSAVE dumps the memory data default: dump.rdb",
  :description => "No Description",
  :required => "optional",
  :default => "dump.rdb",
  :recipes => [
    "app_inmobi_redis::default",
  ]

attribute "app_inmobi_redis/data_dir",
  :display_name => "Data directory for Redis default : /var/lib. redis/<portnum> will be appended by default",
  :description => "No Description",
  :required => "optional",
  :default => "/var/lib",
  :recipes => [
    "app_inmobi_redis::default",
  ]

attribute "app_inmobi_redis/slave_of_line",
  :display_name => "Config line which describes slave configuration if required default: slaveof no one",
  :description => "No Description",
  :required => "optional",
  :recipes => [
    "app_inmobi_redis::default",
  ]

attribute "app_inmobi_redis/max_clients",
  :display_name => "Set the max number of connected clients at the same time. default: 500",
  :required => "optional",
  :default => "500",
  :recipes => [
    "app_inmobi_redis::default",
  ]

attribute "app_inmobi_redis/append_only",
  :display_name => "Mention the configuration for appendonly setting. default: yes", 
  :required => "optional",
  :default => "yes",
  :choice => ["no", "yes"],
  :recipes => [
    "app_inmobi_redis::default",
  ]

attribute "app_inmobi_redis/append_fsync",
  :display_name => "Mention the frequency for appendonly setting. default: everysec", 
  :required => "optional",
  :default => "everysec",
  :choice => ["no", "always", "everysec"],
  :recipes => [
    "app_inmobi_redis::default",
  ]

attribute "app_inmobi_redis/auto_aof_rewrite_percentage",
  :display_name => "BGREWRITEAOF will be performed after AOF file grows to given percentage from previous check. default : 0 (disabled)",
  :required => "optional",
  :default => "0",
  :recipes => [
    "app_inmobi_redis::default",
  ]

attribute "app_inmobi_redis/slowlog_log_slower_than",
  :display_name => "Log queries taking longer than given microseconds in memory. default : 10000",
  :required => "optional",
  :default => "10000",
  :recipes => [
    "app_inmobi_redis::default",
  ]

