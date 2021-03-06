include_recipe "database::mysql"
include_recipe "memcached::config"

group node['apache']['group'] do
    append true
    members node["symfony"]["deploy_user"]
end

node['symfony']['packages'].each do |pkg|
  package pkg do
    action :install
  end
end

# ensure mysql is running
service 'mysql' do
    action :enable
end

# ensure the default site is not enabled
apache_site "default" do
    enable false
end

#
# http://www.elabs.se/blog/57-handle-secret-credentials-in-ruby-on-rails
# http://stackoverflow.com/questions/15411817/get-environment-variables-in-symfony2-parameters-yml
#

# setup directory for app settings
directory "/var/www/vhosts/#{node["symfony"]["application_name"]}/shared/public/app/config" do
    owner node["symfony"]["deploy_user"]
    group node["symfony"]["deploy_group"]
end

# setup db connection and other app settings
template "/var/www/vhosts/#{node["symfony"]["application_name"]}/shared/public/app/config/parameters_secret.yml" do
    action :create
    source "parameters.yml.erb"
    owner node["symfony"]["deploy_user"]
    group node["symfony"]["deploy_group"]
    mode "644"
    variables()
end

# setup database create auth
mysql_connection_info = {
    :host => "localhost",
    :username => 'root',
    :password => node['mysql']['server_root_password']
}

# create database for the environment
database node['symfony']['parameters']['database_name'] do
    provider Chef::Provider::Database::Mysql
    connection mysql_connection_info
    action :create
end

# only create the database user if it's not the root user
unless node['symfony']['parameters']['database_user'] == 'root'
    %w{ localhost 127.0.0.1 }.each do |mysql_remote_host|
        mysql_database_user node['symfony']['parameters']['database_user'] do
            connection mysql_connection_info
            password node['symfony']['parameters']['database_password']
            database_name node['symfony']['parameters']['database_name']
            host mysql_remote_host
            action :grant
        end
    end
end

# create virtual host entry for apache
web_app node['symfony']['server_name'] do
    template 'web_app.conf.erb'
    cookbook 'symfony2' #@cookbook_name
    docroot node['symfony']['server_docroot']
    server_name node['symfony']['server_name']
    server_aliases node['symfony']['server_aliases']
    server_is_canonical node['symfony']['server_is_canonical']
    enable true
end

# note: this SSL install may need to be tweaked, but this is an example of what would need to be done
# install ssl certs if listening to 443
if node['apache']['listen_ports'].include?("443")
    # create ssl dir for where we place certs
    %w{ /etc/httpd/ssl/ssl.crt /etc/httpd/ssl/ssl.key }.each do |dirname|
        directory dirname do
            action :create
            recursive true
        end
    end
    # install the key file
    cookbook_file "/etc/httpd/ssl/ssl.key/#{node['symfony']['server_name']}.key" do
        backup false
        source "ssl/server.key" # this is the value that would be inferred from the path parameter
        mode "0644"
    end
    # install server cert
    cookbook_file "/etc/httpd/ssl/ssl.crt/#{node['symfony']['server_name']}.crt" do
        backup false
        source "ssl/WWW.DOMAIN.COM.crt" # this is the value that would be inferred from the path parameter
        mode "0644"
    end
    # this file is needed too
    cookbook_file "/etc/httpd/ssl/ssl.key/Apache_Plesk_Install.txt" do
        source "ssl/Apache_Plesk_Install.txt" # this is the value that would be inferred from the path parameter
        mode "0644"
        backup false
    end
end


# setup memcache
node['symfony']['memcache_pools'].each do |key,values|
    memcached_instance values['name'] do
        port values['port']
        memory values['memory']
    end
end
