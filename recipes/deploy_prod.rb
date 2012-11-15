deployUser = node['symfony']['user']
deployGroup = node['symfony']['group']
deployRepo = node["symfony"]["repository"]
deployBranch = node["symfony"]["revision"]

environmentVars = ({ 'MYSQL_DB'   => node["symfony"]["mysql_name"],
                     'MYSQL_USER' => node["symfony"]["mysql_user"],
                     'MYSQL_PASS' => node["symfony"]["mysql_pass"],
                     'MYSQL_HOST' => node["symfony"]["mysql_host"] })

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
        execute "script/before_migrate.sh" do
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
    migration_command "script/migration.sh"

    # runs after migration
    before_restart do
        execute "script/before_restart.sh" do
            cwd release_path
            environment environmentVars
            user deployUser
            group deployGroup
        end
    end
end
