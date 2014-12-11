include:
  - .syslog
  - .beaver

{% from 'logstash/lib.sls' import logship with context %}
{{ logship('salt-minion.log', '/var/log/salt/minion', 'salt', ['salt','salt-minion','log'], 'json') }}
{{ logship('salt-master.log', '/var/log/salt/master', 'salt', ['salt','salt-master','log'], 'json') }}
{{ logship('salt-key.log',    '/var/log/salt/key',    'salt', ['salt','salt-key','log'], 'json') }}
{% if not salt['pillar.get']('logstash:hide_auditd', False) %}
{{ logship('audit.log', '/var/log/audit/audit.log', 'audit', ['audit'], 'json') }}
{% else %}
/etc/beaver.d/audit.log.conf:
    file:
      - absent
      - watch_in:
        - service: beaver
{% endif %}

{#
we are configuring all 3 to ship even on minions as we can't use wildcard and separate logrotated logs
#}
