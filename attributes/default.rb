# centos 6 with epel-release repo tested
default["symfony"]["packages"] = [ 'wget', 'libjpeg', 'libpng', 'giflib', "php", "php-devel", "php-cli", "php-pear", "php-xml", "php-xmlrpc", "php-mbstring", "php-mysql", "php-pdo", "php-pecl-apc", "php-gd" ]

default['symfony']['server_name'] = 'symfony-app.dev'
default['symfony']['server_aliases'] = ['www.symfony-app.dev']
default['symfony']['server_docroot'] = "/var/www/vhosts/#{default['symfony']['server_name']}/current/public/web"

default['symfony']['mysql_user'] = 'root'
default['symfony']['mysql_pass'] = ''
default['symfony']['mysql_host'] = 'localhost'
default['symfony']['mysql_name'] = 'symfony_dev'

default["symfony"]["repository"] = 'https://github.com/streamlinesocial/app-symfony.git'
default["symfony"]["revision"] = 'master'

default["symfony"]["deploy_user"] = 'apache'
default["symfony"]["deploy_group"] = 'apache'
