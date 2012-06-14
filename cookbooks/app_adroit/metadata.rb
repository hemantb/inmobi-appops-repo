maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs the required adroit servers."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "app"
depends "rightscale"

recipe  "app_adroit::default", "Installs the required adroit debians"

attribute "app_adroit/function",
  :display_name => "Type of Adroit Server",
  :description => "Mention the type of adroit server ex: frontend or backend",
  :choice => [ "frontend", "backend", "gboconsole"],
  :recipes => ["app_adroit::default"],
  :required => "required"
