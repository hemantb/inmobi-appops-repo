remote_recipe "remote recipe for lbchecks" do
  recipe "inmobi_lb_haproxy::runremote.rb"
  attributes { from => @node[:rightscale][:instance_uuid] }
  recipients_tags ["loadbalancer:cms=lb"]
end
