maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
#license          IO.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'LICENSE')))
description      "Installs/configures RightScale premium tools"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.11"

depends "rs_utils"

provides "rs_tools(:name)"

recipe "rs_tools::default", "Installs RightScale Premium Resources gem and dependencies."
