release_path = "/var/www/vhosts/#{node['symfony']['server_name']}"

environmentVars = ()

# setup db connection and other app settings
template "#{release_path}/public/app/config/parameters.yml" do
    action :create
    source "parameters.yml.erb"
    mode "644"
    variables()
end

execute "ant deploy" do
    cwd release_path
    environment environmentVars
end
