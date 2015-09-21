include:
  - bootstrap.syslog

# Set udp as enabled (by default) so that we don't break current
# behaviour, but if not, it should delete the previously
# un-needed file
/etc/rsyslog.d/10-logstash.conf:
  file:
{% if salt['pillar.get']('syslog:udp_enabled', True) %}
    - managed
    - source: salt://logstash/templates/syslog/10-logstash.conf
    - template: jinja
    - watch_in:
      - service: rsyslog
{% else %}
    - absent
{% endif %}

/etc/rsyslog.conf:
  file:
    - managed
    - source: salt://logstash/templates/syslog/rsyslog.conf
    - template: jinja
    - watch_in:
      - service: rsyslog

