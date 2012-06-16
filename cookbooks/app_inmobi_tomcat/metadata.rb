maintainer       "Inmobi"
maintainer_email "bhagyaraj.g@inmobi.com"
license          "Copyright Inmobi, Inc. All rights reserved."
description      "Installs the tomcat application server."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.2.1"

depends "rightscale"
recipe  "app_inmobi_tomcat::default", "Installs the tomcat application server."
recipe  "app_inmobi_tomcat::debinst", "Installs the debians dependent on tomcat"

#Java tuning parameters

attribute "app_inmobi_tomcat/java/xmx",
  :display_name => "Tomcat Java XMX",
  :description => "The java Xmx argument (i.e. 512m)",
  :required => "optional",
  :default => "512m"

attribute "app_inmobi_tomcat/app_user",
  :display_name => "Tomcat process owner",
  :description => "Tomcat process owner (eg: tomcat6)",
  :required => "optional",
  :default => "tomcat6"

attribute "app_inmobi_tomcat/app_group",
  :display_name => "Tomcat process group owner",
  :description => "Tomcat process group owner (eg: tomcat6)",
  :required => "optional",
  :default => "tomcat6"

attribute "app_inmobi_tomcat/java/MaxPermSize",
  :display_name => "Tomcat Java MaxPermSize",
  :description => "The java MaxPermSize argument (i.e. 256m)",
  :required => "optional",
  :default => "256m"

attribute "app_inmobi_tomcat/java/JmxPort",
  :display_name => "Tomcat JMX port number",
  :description => "The jmx port number argument (i.e. 9004)",
  :required => "optional",
  :default => "9004"

attribute "app_inmobi_tomcat/java/HeapDumpPath",
  :display_name => "Tomcat Java HeapDumpPath",
  :description => "The java HeapDumpPath argument (i.e. /var/log/tomcat6/dump.tmp)",
  :required => "optional",
  :default => "/var/log/tomcat6/dump.tmp"

attribute "app_inmobi_tomcat/java/ExtraOpts",
  :display_name => "Tomcat Java extra options",
  :description => "The tomcat extra options to be passed to the java process",
  :required => "optional",
  :default => "-XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -XX:+CMSIncrementalPacing -XX:CMSIncrementalDutyCycleMin=0"

attribute "app_inmobi_tomcat/port",
  :display_name => "Tomcat Java port number",
  :description => "The port number Tomcat process should listen to",
  :required => "optional",
  :default => "8080"

attribute "app_inmobi_tomcat/base",
  :display_name => "Tomcat Java appBase parameter",
  :description => "The Tomcat Jave appBase parameter configured in server.xml",
  :required => "optional",
  :default => "webapps"

attribute "app_inmobi_tomcat/webapp/debians",
  :display_name => "Give space separated list of pkg1=version1,pkg2=version2,... entries",
  :description => "If version number is omitted packagename with latest version will be installed",
  :required => true,
  :recipes => [ "app_inmobi_tomcat::debinst" ]

attribute "app_inmobi_tomcat/webapp/restart",
  :display_name => "Mention if tomcat needs to be restarted after debian install",
  :description => "Choices true or false",
  :required => "optional",
  :default => "true",
  :choice => ["true","false"],
  :recipes => [ "app_inmobi_tomcat::debinst" ]
