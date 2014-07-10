## Version 1.1.x

* Create a basic apparmor profile for logstash and related services.

## Version 1.0.8

* Fix for Allow to enable/disable client monitoring

## Version 1.0.7

* Allow to enable/disable client monitoring. By default it's enabled.

## Version 1.0.6

* Depend on more recent version of python-formula

## Version 1.0.5

* Configurable easticsearch host address and javascript based default for it

## Version 1.0.4

* Ensure all salt related logs (minion,master,keys) are shipped from beaver

## Version 1.0.3

* Updated elasticsearch formula dependency to v1.0.2
* Added logstash.elasticsearch pillar variables defined in map.jinja
* Updated kibana to dynamically use elasticsearch.<domain>:8080 by default
* Renamed elasticsearch references and internalised nginx vhost config
* Added config and patterns for handling auditd log entries
* Fixed dependencies for beaver/logstash config directories to enforce highstate order

## Version 1.0.2

* Fixed YAML layout causing highstate failure

## Version 1.0.1

* Replaced supervisord with upstart for beaver - fixes beaver restart problem
* All server definitions now default to monitoring.local instead of localhost
* Fixed ordering of grok rules in logstash to avoid possible parsing errors
* Ensure syslog generates FQDN hostnames

## Version 1.0.0

* Initial checkin

