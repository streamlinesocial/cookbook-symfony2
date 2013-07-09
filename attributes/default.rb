# centos 6 with epel-release repo tested
default["symfony"]["packages"] = [ 'wget', 'libjpeg', 'libpng', 'giflib', 'telnet' ]

default['symfony']['server_name'] = 'symfony-app.dev'
default['symfony']['server_aliases'] = ['www.symfony-app.dev']
default['symfony']['server_docroot'] = "/var/www/vhosts/#{default['symfony']['server_name']}/current/public/web"
default['symfony']['server_is_canonical'] = true

# used to construct the yml file
default['symfony']['parameters']['database_driver']     = "pdo_mysql"
default['symfony']['parameters']['database_host']       = "localhost"
default['symfony']['parameters']['database_port']       = "~"
default['symfony']['parameters']['database_name']       = "symfony_dev"
default['symfony']['parameters']['database_user']       = "root"
default['symfony']['parameters']['database_password']   = ""
default['symfony']['parameters']['mailer_transport']    = "smtp"
default['symfony']['parameters']['mailer_host']         = "localhost"
default['symfony']['parameters']['mailer_user']         = "~"
default['symfony']['parameters']['mailer_password']     = "~"
default['symfony']['parameters']['locale']              = "en"
default['symfony']['parameters']['secret']              = "ThisTokenIsNotSoSecretChangeIt"

default["symfony"]["repository"] = 'https://github.com/streamlinesocial/app-symfony.git'
default["symfony"]["revision"] = 'master'

default["symfony"]["deploy_user"] = 'apache'
default["symfony"]["deploy_group"] = 'apache'
default["symfony"]["deploy_key_bag_item"] = 'symfony-app'

# 200 mb max for a 2GB server
# 16mb = 16777216/2000 = 8388.608 users logged in before they get logged out by memcache
default["symfony"]["memcache_pools"] = {
    "sessions" => {
        "name" => "sessions",
        "port" => 11211,
        "memory" => 16
    },
    "doctrine" => {
        "name" => "doctrine",
        "port" => 11212,
        "memory" => 184
    }
}

# example format commented out
default["symfony"]["crons"] = {
    # 'cron_key' = {
    #     'minute'  => '*',
    #     'hour'    => '*',
    #     'day'     => '*',
    #     'month'   => '*',
    #     'weekday' => '*',
    #     'action'  => 'create',
    #     'command' => 'cd /var/somewhere && ./app/console do:something'
    # }
}
