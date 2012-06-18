rightscale_marker :begin

  execute "update apt cache" do
    command "apt-get update"
    ignore_failure true
  end

  depends = ["gcc", "tcl8.5", "mkhoj-base"]

  depends.each do |p|
    package p do
      options "--force-yes"
    end
  end

  remote_file "/tmp/redis-server-2.4.8.tar.gz" do
    source "redis-server-2.4.8.tar.gz"
    mode "0755"
  end

  node[:app_inmobi_redis][:installed] = "false"

  if node[:app_inmobi_redis][:installed] == "false"
    script "install_redis_server" do
     interpreter "bash -ex"
      code <<-EOF
        cd /tmp
        tar -zxvf redis-server-2.4.8.tar.gz
        cd redis-2.4.8
        echo "running make" >> /opt/mkhoj/logs/redis_install_log
        date >> /opt/mkhoj/logs/redis_install_log
        make >> /opt/mkhoj/logs/redis_install_log
        echo "running make test" >> /opt/mkhoj/logs/redis_install_log
        make test >> /opt/mkhoj/logs/redis_install_log
        echo "running make install" >> /opt/mkhoj/logs/redis_install_log
        make install >> /opt/mkhoj/logs/redis_install_log
      EOF
    end
  else
    log "Redis 2.4.8 has already been installed once. Not installing again"
  end

  service "redis_#{node[:app_inmobi_redis][:redis_port]}" do
    action :nothing
  end

  log "  Creating /etc/init.d/redis_#{node[:app_inmobi_redis][:redis_port]}"
  template "/etc/init.d/redis_#{node[:app_inmobi_redis][:redis_port]}" do
    action :create
    source "redis-init-script.erb"
    group "root"
    owner "root"
    mode "0755"
    variables(
      :redis_port => node[:app_inmobi_redis][:redis_port]
    )
    notifies :restart , resources(:service => "redis_#{node[:app_inmobi_redis][:redis_port]}")
  end

  log "  Creating /opt/mkhoj/conf/redis/redis_#{node[:app_inmobi_redis][:redis_port]}.conf"

  directory "/opt/mkhoj/conf/redis" do
    owner "root"
    group "root"
    mode "0755"
    action :create
    recursive true
  end
 
  directory "/opt/mkhoj/logs/redis" do
    owner "root"
    group "root"
    mode "0755"
    action :create
    recursive true
  end

  directory "#{node[:app_inmobi_redis][:data_dir]}/redis/#{node[:app_inmobi_redis][:redis_port]}" do
    owner "root"
    group "root"
    mode "0755"
    action :create
    recursive true
  end

  template "/opt/mkhoj/conf/redis/redis_#{node[:app_inmobi_redis][:redis_port]}.conf" do
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

  include_recipe "rightscale::setup_server_tags"
#  include_recipe "rightscale::setup_monitoring"

  right_link_tag "appserver:active=true"
  right_link_tag "appserver:listen_ip=#{node[:app][:ip]}"

  node[:app_inmobi_redis][:installed] = "true"

rightscale_marker :end
