include:
  - .syslog
  - .beaver

{% from 'logstash/lib.sls' import logship with context %}
{{ logship('salt-minion.log', '/var/log/salt/minion', 'salt', ['salt','salt-minion','log'], 'json') }}
{{ logship('salt-master.log', '/var/log/salt/master', 'salt', ['salt','salt-master','log'], 'json') }}
{{ logship('salt-key.log',    '/var/log/salt/key',    'salt', ['salt','salt-key','log'], 'json') }}
{{ logship('kern.log', '/var/log/kern.log', 'kernel', ['kernel'], 'json') }}

{#
we are configuring all 3 to ship even on minions as we can't use wildcard and separate logrotated logs
#}
