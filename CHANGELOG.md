## UNRELEASED

* Add option to turn udp logging on and off (syslog:udp_enabled)

## Version 1.7.6

* Fix logstash beaver by removing the python-pip requirement that is no
  longer required

## Version 1.7.5

* Add an ability to customize the `redis_namespace`

## Version 1.7.4

* Bugfix: missing trailing comma

## Version 1.7.3

* Add an ability to set the number of `redis_input_threads` that
  logstash consumes from. Default is normally 1, here we have used 6.

## Version 1.7.2

* Add an ability to set `server_name` for the nginx virtual host for
  both the Kibana  and Leasticsearch via a pillar. The default value
  is set via `map.jinja`.

## Version 1.7.1

* Pin python-daemon so that beaver installs successfully.

## Version 1.7.0

* Handle mongodb.log: mark-up and send to statsd

## Version 1.6.0

* Log _grokparsefailure messages to a file for reprocessing (enabled by default)

## Version 1.5.3

* Allow specification of statsd output port/host
* Fix restart bug

## Version 1.5.2

* Bump versions of dependencies: utils-formula; apparmor-formula

## Version 1.5.1

* Fix conf.d management so reload only happens when it changes

## Version 1.5.0

* Add input unix socket handler for log replay
* Add optional archive logging
* Add statsd logging of key events

## Version 1.4.0

* Upgrade to Logstash 1.4.2, via official packages
* Move to conf.d configuration style
* Various bugfixes, particularly around kv{} usage

## Version 1.2.0

* Process auditd logs, including apparmor via auditd

## Version 1.1.0

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

