maintainer        "Streamline Social"
maintainer_email  "support@streamlinesocial.com"
license           "Apache 2.0"
description       "Installs a Symfony2 web app"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.0"
recipe            "symfony2", "Setup the webserver components and the required yum packages."
recipe            "symfony2::deploy_symfony", "Installs the Symfony2 app"

%w{ centos }.each do |os|
  supports os
end

%w{ iptables, mysql, apache2, database }.each do |cb|
  depends cb
end
