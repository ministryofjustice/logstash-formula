include:
  - bootstrap.syslog

{% if 'shipper' in grains['roles'] or 'aggregator' in grains['roles'] %}
/etc/rsyslog.d/10-logstash.conf:
  file:
    - managed
    - source: salt://logging/templates/syslog/10-logstash.conf
    - template: jinja
    - watch_in:
      - service: rsyslog

{% endif %}
