rightscale_marker :begin

  execute "update apt cache" do
    command "apt-get update"
    ignore_failure true
  end

  depends = ["gcc","tcl8.5"]

  depends.each do |p|
    package p do
      options "--force-yes"
    end
  end

  redis_tar = "redis-server-2.4.8.tar.gz"

  remote_file "/tmp/#{redis_tar}" do
    source "redis-server-2.4.8.tar.gz"
    mode "0755"
  end

  script "install_redis_server" do
   interpreter "bash -ex"
    code <<-EOF
      cd /tmp
      tar -zxvf #{redis-tar}
      cd redis-2.4.8
      echo "running make" >> /tmp/redis_install_log
      make >> /tmp/redis_install_log
      echo "running make test" >> /tmp/redis_install_log
      make test >> /tmp/redis_install_log
      echo "running make install" >> /tmp/redis_install_log
      make install >> /tmp/redis_install_log
    EOF
  end

  service "redis_#{node[:app_inmobi_redis][:redis_port]}" do
    action :nothing
  end

  log "  Creating /etc/init.d/redis_#{node[:app_inmobi_redis][:redis_port]}"
  template "/etc/init.d/#{node[:app_inmobi_redis][:redis_port]}" do
    action :create
    source "redis-init-script.erb"
    group "root"
    owner "root"
    mode "0644"
    variables(
      :redis_port => node[:app_inmobi_redis][:redis_port]
    )
    notifies :restart , resources(:service => "redis_#{node[:app_inmobi_redis][:redis_port]}")
  end

  log "  Creating /opt/mkhoj/conf/redis/redis_#{node[:app_inmobi_redis][:redis_port]}"
  template "/opt/mkhoj/conf/redis/redis_#{node[:app_inmobi_redis][:redis_port]}" do
    action :create
    source "redis-conf.erb"
    group "root"
    owner "root"
    mode "0644"
    variables(
     :redis_port => node[:app_inmobi_redis][:redis_port],
     :bind_address =>  node[:app_inmobi_redis][:bind_address],
     :client_timeout =>  node[:app_inmobi_redis][:client_timeout],
     :db_num =>  node[:app_inmobi_redis][:db_num],
     :bgsave_line =>  node[:app_inmobi_redis][:bgsave_line],
     :dump_file =>  node[:app_inmobi_redis][:dump_file],
     :data_dir =>  node[:app_inmobi_redis][:data_dir],
     :slave_of_line =>  node[:app_inmobi_redis][:slave_of_line],
     :max_clients =>  node[:app_inmobi_redis][:max_clients],
     :append_only =>  node[:app_inmobi_redis][:append_only],
     :append_fsync => node[:app_inmobi_redis][:append_fsync],
     :auto_aof_rewrite_percentage =>  node[:app_inmobi_redis][:auto_aof_rewrite_percentage],
     :slowlog_log_slower_than => node[:app_inmobi_redis][:slowlog_log_slower_than]
    )
    notifies :restart , resources(:service => "redis_#{node[:app_inmobi_redis][:redis_port]}")
  end

right_link_tag "appserver:active=true"
right_link_tag "appserver:listen_ip=#{node[:app][:ip]}"

rightscale_marker :end
