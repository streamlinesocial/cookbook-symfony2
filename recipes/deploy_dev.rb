shared_path = "/var/www/vhosts/#{node['symfony']['server_name']}/shared"
release_path = "/var/www/vhosts/#{node['symfony']['server_name']}/current"

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
directory "/var/www/vhosts/#{node['symfony']['server_name']}" do
    action :create
    mode "0775"
    recursive true
    # owner node['symfony']['deploy_user']
    # group node['symfony']['deploy_group']
end

#create shared config dirs
%w{ shared shared/config shared/uploads shared/media shared/vendor }.each do |createDir|
    directory "/var/www/vhosts/#{node['symfony']['server_name']}/#{createDir}" do
        action :create
        # owner node['symfony']['deploy_user']
        # group node['symfony']['deploy_group']
        recursive true
    end
end

# setup db connection and other app settings
template "/var/www/vhosts/#{node['symfony']['server_name']}/shared/config/parameters.ini" do
    action :create
    source "parameters.ini.erb"
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

git release_path do
    action :checkout # can be sync also for auto-updates
    repository deployRepo
    revision deployBranch
    # user deployUser
    # group deployGroup
    depth 5 # mimic deploy_resource shallow_clone true
    ssh_wrapper "/tmp/private_key/wrap-ssh4git.sh"
end

# before_migrate
# setup vendors and ensure install
execute "script/before_migrate.sh" do
    cwd release_path
    environment environmentVars
    # user deployUser
    # group deployGroup
end

# setup configs for before migrate
symlink_before_migrate = {
    "config/parameters.ini" => "public/app/config/parameters.ini"
}

symlink_before_migrate.each do |target,symlink|
    link "#{release_path}/#{symlink}" do
        to "#{shared_path}/#{target}"
    end
end

# ================================================
# # runs after before_migrate
# # purge_before_symlink
# %w{ public/web/uploads  public/web/media }.each do |target|
#     execute "rm -rf #{target}" do
#         cwd release_path
#     end
# end
# 
# # create_dirs_before_symlink
# %w{}.each do |target|
#     directory "#{release_path}/#{target}" do
#         action :create
#         # owner deployUser
#         # group deployGroup
#     end
# end
# 
# # symlinks
# symlinks = {"uploads" => "public/web/uploads",
#             "media"   => "public/web/media"}
# 
# symlinks.each do |sharedTarget,releaseLink|
#     link "#{release_path}/#{releaseLink}" do
#         to "#{shared_path}/#{sharedTarget}"
#         # owner deployUser
#         # group deployGroup
#     end
# end
# ================================================

# migration_command
# runs after symlinks are created
# execute "script/migration.sh" do
#     environment environmentVars
#     cwd release_path
#     # user deployUser
#     # group deployGroup
# end
# 
# # runs after migration
# execute "script/before_restart.sh" do
#     environment environmentVars
#     cwd release_path
#     # user deployUser
#     # group deployGroup
# end
