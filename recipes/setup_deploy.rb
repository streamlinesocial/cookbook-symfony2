# creates /tmp/private_key/wrap-ssh4git.sh
sls_utils_deploy_key node['symfony']['deploy_user'] do
    action :create
    deploy_key_bag_item "symfony-app"
end
