# ensure xml libs available (using ius repo to get newer version of php 5.3.xx than centos default)
%w{ wget libjpeg libpng giflib php53u-xml php53u-xmlrpc php53u-mbstring php53u-mysql php53u-pdo php53u-pecl-apc php53u-gd }.each do |pkg|
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

# create virtual host entry for apache
web_app node['symfony']['server_name'] do
    template 'web_app.conf.erb'
    cookbook 'symfony2' #@cookbook_name
    docroot "/var/www/vhosts/#{node['symfony']['server_name']}/current/public/web"
    server_name node['symfony']['server_name']
    server_aliases node['symfony']['server_aliases']
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
