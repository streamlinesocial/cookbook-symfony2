deployUser = node['symfony']['user']
deployGroup = node['symfony']['group']
deployRepo = node["symfony"]["repository"]
deployBranch = node["symfony"]["revision"]

environmentVars = ({ 'MYSQL_DB'   => node["symfony"]["mysql_name"],
                     'MYSQL_USER' => node["symfony"]["mysql_user"],
                     'MYSQL_PASS' => node["symfony"]["mysql_pass"],
                     'MYSQL_HOST' => node["symfony"]["mysql_host"] })

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

# either deploy_revision or deploy (timestamp)
deploy_revision "/var/www/vhosts/#{node['symfony']['server_name']}" do

    action :deploy # or :rollback or force_deploy

    repository deployRepo
    revision deployBranch
    shallow_clone true
    ssh_wrapper "/tmp/private_key/wrap-ssh4git.sh"

    user deployUser
    group deployGroup

    # setup configs for before migrate
    symlink_before_migrate({"config/parameters.ini" => "public/app/config/parameters.ini"})

    # setup vendors and ensure install
    before_migrate do
        execute "script/deploy/before_migrate.sh" do
            cwd release_path
            environment environmentVars
            user deployUser
            group deployGroup
        end
    end

    # runs after before_migrate
    purge_before_symlink %w{ public/web/uploads  public/web/media }
    create_dirs_before_symlink %w{}
    symlinks({"uploads" => "public/web/uploads",
              "media"   => "public/web/media"})

    # runs after symlinks are created
    migrate true
    environment environmentVars
    migration_command "script/deploy/migration.sh"

    # runs after migration
    before_restart do
        execute "script/deploy/before_restart.sh" do
            cwd release_path
            environment environmentVars
            user deployUser
            group deployGroup
        end
    end
end
