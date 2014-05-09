## Version 1.0.2

* Fixed YAML layout causing highstate failure

## Version 1.0.1

* Replaced supervisord with upstart for beaver - fixes beaver restart problem
* All server definitions now default to monitoring.local instead of localhost
* Fixed ordering of grok rules in logstash to avoid possible parsing errors
* Ensure syslog generates FQDN hostnames

## Version 1.0.0

* Initial checkin

