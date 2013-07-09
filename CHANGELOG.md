1.5.0
=====

- Remove memcached requirement at the cookbook level, should be recommends at most.
- Add telnet to default package installed, for debugging mainly.
- Add include_recipe for memcached::config to setup the dependency for memcached functions.

1.4.3
=====

- Update log location for the ant runs to be stored in /var/log/ant/date.log format, so we dont overwrite past logs.

1.4.2
=====

- Add env var to the recipe for composer to set the cache dir, make it live in the shared dir for permissions reasons

1.4.1
=====

- Add deps for other recipes needed in the prod deploy recipe

1.4.0
=====

- Add requirement of memcached
- Start / Enable memcached service in prod

1.3.1
=====

- Added restart apache call after deploy
- Added place to configure sessions to be stored and shared between app deploys
- Added symfony rewrite rules into the vhost configs

1.3.0
=====

- Added ability to turn on/off canonical redirect via node attribs

1.2.0
=====

- Added tweaks to params to enable more control over the parameters.yml config file in the attributes
- Added dependency for ant/java for builds
- Added use of database_user resource to create database in setups with non-root user access
- Added attrib to be able to define the data_bag that contains the deploy key for the symfony app

1.1.0
=====

- Tweak location of the deploy scripts, move to script/deploy/*.sh to enhance readability of project script folders.
- remove hard-use of the ius packages. move packages to attribs

1.0.0
=====

- Initial creation
