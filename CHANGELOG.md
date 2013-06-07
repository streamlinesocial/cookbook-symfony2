1.4.0
=====

- Add requirement of memcached

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
