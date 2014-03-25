include:
  - bootstrap.syslog

/etc/rsyslog.d/10-logstash.conf:
  file:
    - managed
    - source: salt://logging/templates/syslog/10-logstash.conf
    - template: jinja
    - watch_in:
      - service: rsyslog
