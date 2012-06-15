a = "Hello".gsub(/H/,"h")

remote_recipe "Attach me to load balancer" do
    recipe "inmobi_lb_haproxy::runremote"
    attributes :remote_recipe => {
      :vhost_names => "cmsapplicationhost"
    }
    recipients_tags "loadbalancer:cms=lb"
end
