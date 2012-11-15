# ensure our deployment dir exists
directory "/var/www/vhosts/#{node['symfony']['server_name']}" do
    action :create
    mode "0775"
    recursive true
    owner node['symfony']['deploy_user']
    group node['symfony']['deploy_group']
end

#create shared config dirs
%w{ shared shared/config shared/uploads shared/media shared/vendor }.each do |createDir|
    directory "/var/www/vhosts/#{node['symfony']['server_name']}/#{createDir}" do
        action :create
        owner node['symfony']['deploy_user']
        group node['symfony']['deploy_group']
        recursive true
    end
end

# setup db connection and other app settings
template "/var/www/vhosts/#{node['symfony']['server_name']}/shared/config/parameters.ini" do
    action :create
    source "parameters.ini.erb"
    owner node['symfony']['deploy_user']
    group node['symfony']['deploy_group']
    mode "644"
    variables(
        :mysql_user => node['symfony']['mysql_user'],
        :mysql_pass => node['symfony']['mysql_pass'],
        :mysql_host => node['symfony']['mysql_host'],
        :mysql_name => node['symfony']['mysql_name']
    )
end

# creates /tmp/private_key/wrap-ssh4git.sh
sls_utils_deploy_key node['symfony']['deploy_user'] do
    action :create
    deploy_key_bag_item "symfony-app"
end
