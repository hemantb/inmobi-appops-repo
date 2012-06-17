maintainer       "Inmobi"
maintainer_email "bhagyaraj.g@inmobi.com"
license          "All rights reserved"
description      "Installs/Configures app_inmobi_debinst"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

recipe "app_inmobi_debinst" , "Installs debians supporting custom start-stop script eg: daemontools"

attribute "app_inmobi_debinst/service",
  :display_name => "Mention the generic service name.",
  :description => "This name will be used as init.d service name if start-stop commands are not mentioned",
  :required => true,
  :default => nil

attribute "app_inmobi_debinst/debians",
  :display_name => "Mention the debians and thier versions in packagename=version format",
  :description => "If latest? is set to true, and if version numbers are missing in the debian names the latest package will be installed",
  :required => true,
  :default => nil

attribute "app_inmobi_debinst/latest",
  :display_name => "Mention if latest package should be installed if version name is mentioned for a packagename in debians list",
  :description => "If latest? is set to true, and if version numbers are missing in the debian names the latest package will be installed",
  :required => "optional",
  :default => "false",
  :choice => ["true","false"]

attribute "app_inmobi_debinst/restart",
  :display_name => "Mention if service needs to be restarted after debian installations",
  :description => "Select if service needs to be restarted after debian installations",
  :required => "optional",
  :default => "false",
  :choice => ["true","false"]

attribute "app_inmobi_debinst/starcmd",
  :display_name => "Mention the complete command used to start the service",
  :description => "Eg: svc -u /etc/service-puppet",
  :required => "optional",
  :default => nil

attribute "app_inmobi_debinst/stopcmd",
  :display_name => "Mention the complete command used to stop the service",
  :description => "Eg: svc -d /etc/service-puppet",
  :required => "optional",
  :default => nil
