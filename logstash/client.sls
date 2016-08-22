include:
  - .syslog
  - .beaver

{% from 'logstash/lib.sls' import logship with context %}
{% from "logstash/map.jinja" import beaver with context %}

# We always ignore salt-minion logs
{{ logship('salt-minion.log', '/var/log/salt/minion', 'salt', ['salt','salt-minion','log'], 'json', absent=True) }}

{% if beaver.activate_plugins.get('salt-master', False) %}
{{ logship('salt-master.log', '/var/log/salt/master', 'salt', ['salt','salt-master','log'], 'json') }}
{% endif %}
{% if beaver.activate_plugins.get('salt-key', False) %}
{{ logship('salt-key.log',    '/var/log/salt/key',    'salt', ['salt','salt-key','log'], 'json') }}
{% endif %}
{% if beaver.activate_plugins.get('auditd', False) %}
{{ logship('audit.log', '/var/log/audit/audit.log', 'audit', ['audit'], 'json') }}
{% endif %}

{#
we are configuring all 3 to ship even on minions as we can't use wildcard and separate logrotated logs
#}
