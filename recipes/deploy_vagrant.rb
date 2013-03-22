release_path = "/var/www/vhosts/#{node['symfony']['server_name']}"

environmentVars = ()

# setup db connection and other app settings
template "#{release_path}/public/app/config/parameters.yml" do
    action :create
    source "parameters.yml.erb"
    # owner node['symfony']['deploy_user']
    # group node['symfony']['deploy_group']
    mode "644"
    variables()
end

# before_migrate
# setup vendors and ensure install
execute "ant deploy" do
    cwd release_path
    environment environmentVars
end
