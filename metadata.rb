maintainer        "Streamline Social"
maintainer_email  "support@streamlinesocial.com"
license           "Apache 2.0"
description       "Installs a Symfony2 web app"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.4.0"
recipe            "symfony2", "Setup the webserver components and the required yum packages."
recipe            "symfony2::deploy_prod", "Installs the Symfony2 app in ideal production env"
recipe            "symfony2::deploy_vagrant", "Installs the Symfony2 app in ideal vagrant environemnt for dev"
recipe            "symfony2::setup_deploy", "Configures the deploy key"
recipe            "symfony2::setup_lamp", "Configures the databases and other settings pre-deploy"

depends "ant"
depends "composer"
depends "database"
depends "memcached"

%w{ centos }.each do |os|
  supports os
end

