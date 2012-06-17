#
# Cookbook Name:: mytest
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

log "adding new test"

remote_file "/tmp/testfile" do
	source "testfile"
	mode "0644"
end

bash "test" do
        flags "-ex"
	code <<-EOF
		ls
	EOF
end
