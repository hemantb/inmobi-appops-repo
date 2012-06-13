maintainer       "Inmobi"
maintainer_email "bhagyaraj.g@inmobi.com"
license          "Copyright Inmobi, Inc. All rights reserved."
description      "Installs the tomcat application server."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.2.1"

recipe  "app_inmobi_tomcat::default", "Installs the tomcat application server."

#Java tuning parameters

attribute "app_tomcat/java/xmx",
  :display_name => "Tomcat Java XMX",
  :description => "The java Xmx argument (i.e. 512m)",
  :required => "optional",
  :default => "512m"

attribute "app_tomcat/java/MaxPermSize",
  :display_name => "Tomcat Java MaxPermSize",
  :description => "The java MaxPermSize argument (i.e. 256m)",
  :required => "optional",
  :default => "256m"

attribute "app_tomcat/java/JmxPort",
  :display_name => "Tomcat JMX port number",
  :description => "The jmx port number argument (i.e. 9004)",
  :required => "optional",
  :default => "9004"

attribute "app_tomcat/java/HeapDumpPath",
  :display_name => "Tomcat Java HeapDumpPath",
  :description => "The java HeapDumpPath argument (i.e. /var/log/tomcat6/dump.tmp)",
  :required => "recommended",
  :default => "/var/log/tomcat6/dump.tmp"
