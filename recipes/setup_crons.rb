# setup cron jobs based on the attributes for this symfony node
node['symfony']['crons'].each do |key,values|

    # set defaults so we don't break the loop
    defaults = {
        'user'    => node['symfony']['deploy_user'],
        'minute'  => '*',
        'hour'    => '*',
        'day'     => '*',
        'month'   => '*',
        'weekday' => '*',
        'action'  => 'create'
    }

    # leave 'command' out of defaults, its considered a required and we want chef to crash to indicate as such

    # merge values overwriting defaults
    values = defaults.merge(values)

    # alter the command to be rooted in the apps deploy directory
    values['command'] = "cd /var/www/vhosts/#{node['symfony']['server_name']}/current; #{values['command']}"

    # use key as a suffix for the cron name
    cron "symfony_#{key}" do
        user        values['user']
        minute      values['minute']
        hour        values['hour']
        day         values['day']
        month       values['month']
        weekday     values['weekday']
        command     values['command']

        # define the create or delete
        case values['action']
        when 'delete'
            action :delete
        else
            action :create
        end
    end
end
