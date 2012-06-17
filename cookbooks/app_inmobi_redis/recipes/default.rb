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
    chmod 755
  end

  script "install redis server" do
   interpreter "bash -ex"
    code <<-EOF
      cd /tmp
      tar -zxvf #{redis-tar}
      cd redis-2.4.8
      make
      make test
      make install
    EOF
  end

  service "redis_#{node[:app_inmobi_redis][:port]}" do
    action :nothing
  end

  log "  Creating /etc/init.d/redis_#{node[:app_inmobi_redis][:port]}"
  template "/etc/init.d/#{node[:app_inmobi_redis][:port]}" do
    action :create
    source "redis-init-script.erb"
    group "root"
    owner "root"
    mode "0644"
    variables(
      :redis_exe => node[:app_inmobi_redis][:redis_exe]
    )
    notifies :restart , resources(:service => "redis_#{node[:app_inmobi_redis][:port]}")
  end

  log "  Creating /opt/mkhoj/conf/redis/redis_#{node[:app_inmobi_redis][:port]}"
  template "/opt/mkhoj/conf/redis/redis_#{node[:app_inmobi_redis][:port]}" do
    action :create
    source "redis-conf.erb"
    group "root"
    owner "root"
    mode "0644"
    variables(
      :redis_exe => node[:app_inmobi_redis][:redis_exe]
    )
    notifies :restart , resources(:service => "redis_#{node[:app_inmobi_redis][:port]}")
  end

right_link_tag "appserver:active=true"
right_link_tag "appserver:listen_ip=#{node[:app][:ip]}"

rightscale_marker :end
