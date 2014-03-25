{% set jar_name='logstash-1.2.2-flatjar.jar' %}
{% set jar_md5='f2ec9e54e13428ed6d5c96b218126a0e' %}
{% from 'utils/apps/lib.sls' import app_skeleton with context %}

#TODO: upgrade to logstash 1.3.3 as soon as it's gonna be available

include:
  - .deps
  - java
  - redis

#  - log_aggregation.elasticsearch
#  - log_aggregation.agent
#  - log_aggregation.kibana


{{ app_skeleton('logstash') }}


logstash-indexer:
  service:
    - running
    - enable: True
    - require:
      - user: logstash
    - watch:
      - file: /etc/logstash/indexer.conf
      - file: /etc/init/logstash-indexer.conf
      - file: /usr/src/packages/{{jar_name}}


/usr/src/packages/{{jar_name}}:
  file:
    - managed
    - source: http://static.dsd.io/packages/{{jar_name}}
    - source_hash: md5={{jar_md5}}
    - mode: 644
    - require:
      - file: /usr/src/packages


/etc/init/logstash-indexer.conf:
  file:
    - managed
    - source: salt://logging/templates/logstash/init/logstash-indexer.conf
    - template: jinja
    - context:
      jar_name: {{jar_name}}


/etc/logstash:
  file:
    - directory
    - user: logstash
    - group: logstash
    - mode: 755


/etc/logstash/indexer.conf:
  file:
    - managed
    - source: salt://logging/templates/logstash/indexer.conf
    - template: jinja
    - mode: 644
    - user: logstash
    - group: logstash
    - mode: 644


{% from 'firewall/lib.sls' import firewall_enable with  context %}
{{ firewall_enable('logstash-syslog',2514,proto='tcp') }}
{{ firewall_enable('logstash-syslog',2514,proto='udp') }}
