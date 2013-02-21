release_path = "/var/www/vhosts/#{node['symfony']['server_name']}"

deployUser = node["symfony"]["deploy_user"]
deployGroup = node["symfony"]["deploy_group"]
deployRepo = node["symfony"]["repository"]
deployBranch = node["symfony"]["revision"]

environmentVars = ({ 'MYSQL_DB'     => node["symfony"]["mysql_name"],
                     'MYSQL_USER'   => node["symfony"]["mysql_user"],
                     'MYSQL_PASS'   => node["symfony"]["mysql_pass"],
                     'MYSQL_HOST'   => node["symfony"]["mysql_host"],
                     'APACHE_USER'  => node["apache"]["user"],
                     'APACHE_GROUP' => node["apache"]["group"] })

# ensure our deployment dir exists
directory "/var/www/vhosts" do
    mode "0775"
    recursive true
    # owner node['symfony']['deploy_user']
    # group node['symfony']['deploy_group']
end

git release_path do
    action :checkout # can be sync also for auto-updates
    repository deployRepo
    revision deployBranch
    # user deployUser
    # group deployGroup
    depth 5 # mimic deploy_resource shallow_clone true
    ssh_wrapper "/tmp/private_key/wrap-ssh4git.sh"
end

# setup db connection and other app settings
template "#{release_path}/public/app/config/parameters.yml" do
    action :create
    source "parameters.yml.erb"
    # owner node['symfony']['deploy_user']
    # group node['symfony']['deploy_group']
    mode "644"
    variables(
        :mysql_user => node['symfony']['mysql_user'],
        :mysql_pass => node['symfony']['mysql_pass'],
        :mysql_host => node['symfony']['mysql_host'],
        :mysql_name => node['symfony']['mysql_name']
    )
end

# before_migrate
# setup vendors and ensure install
execute "script/deploy/before_migrate.sh" do
    cwd release_path
    environment environmentVars
    # user deployUser
    # group deployGroup
end

# migration_command
# runs after symlinks are created
execute "script/deploy/migration.sh" do
    environment environmentVars
    cwd release_path
    # user deployUser
    # group deployGroup
end

# runs after migration
execute "script/deploy/before_restart.sh" do
    environment environmentVars
    cwd release_path
    # user deployUser
    # group deployGroup
end
