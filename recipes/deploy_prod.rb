include_recipe "memcached"

environmentVars = ({})

# ensure our deployment dir exists
directory "/var/www/vhosts/#{node['symfony']['server_name']}" do
    action :create
    mode "0775"
    recursive true
    owner node['symfony']['deploy_user']
    group node['symfony']['deploy_group']
end

#create shared config dirs
%w{ shared shared/config shared/public_files shared/sessions }.each do |createDir|
    directory "/var/www/vhosts/#{node['symfony']['server_name']}/#{createDir}" do
        action :create
        owner node['symfony']['deploy_user']
        group node['symfony']['deploy_group']
        recursive true
    end
end

# setup db connection and other app settings
template "/var/www/vhosts/#{node['symfony']['server_name']}/shared/config/parameters.yml" do
    action :create
    source "parameters.yml.erb"
    owner node['symfony']['deploy_user']
    group node['symfony']['deploy_group']
    mode "644"
    variables()
end

# either deploy_revision or deploy (timestamp)
deploy_revision "/var/www/vhosts/#{node['symfony']['server_name']}" do

    action :deploy # or :rollback or force_deploy

    repository node["symfony"]["repository"]
    revision node["symfony"]["revision"]
    shallow_clone true
    ssh_wrapper "/tmp/private_key/wrap-ssh4git.sh"

    user node['symfony']['deploy_user']
    group node['symfony']['deploy_group']

    # setup configs for before migrate
    symlink_before_migrate({"config/parameters.yml" => "public/app/config/parameters.yml"})

    # runs after before_migrate
    purge_before_symlink(["public/web/files", "public/app/sessions"])
    create_dirs_before_symlink([])
    symlinks({
        "public_files" => "public/web/files",
        "sessions" => "public/app/sessions",
    })

    # runs after symlinks are created
    migrate true
    environment environmentVars
    migration_command "ant deploy -logfile '/var/www/vhosts/#{node['symfony']['server_name']}/shared/ant.log'"

    # restart the apache server (to clear apc or other cache)
    notifies :restart, "service[apache2]", :immediately
end


