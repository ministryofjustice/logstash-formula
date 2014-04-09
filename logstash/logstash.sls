{% from "logstash/map.jinja" import logstash with context %}
{% from 'utils/apps/lib.sls' import app_skeleton with context %}

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
      - file: /usr/src/packages/{{logstash.source.file}}
      - file: /etc/logstash/patterns


/usr/src/packages/{{logstash.source.file}}:
  file:
    - managed
    - source: http://static.dsd.io/packages/{{logstash.source.file}}
    - source_hash: {{logstash.source.hash}}
    - mode: 644
    - require:
      - file: /usr/src/packages


/etc/init/logstash-indexer.conf:
  file:
    - managed
    - source: salt://logstash/templates/logstash/init/logstash-indexer.conf
    - template: jinja
    - context:
      jar_name: {{logstash.source.file}}


/etc/logstash:
  file:
    - directory
    - user: logstash
    - group: logstash
    - mode: 755

/etc/logstash/patterns:
  file:
    - recurse
    - source: salt://logstash/templates/logstash/patterns
    - template: jinja
    - file_mode: 644
    - dir_mode: 755
    - user: logstash
    - group: logstash
    - require:
      - file: /etc/logstash


/etc/logstash/indexer.conf:
  file:
    - managed
    - source: salt://logstash/templates/logstash/indexer.conf
    - template: jinja
    - mode: 644
    - user: logstash
    - group: logstash


{% from 'firewall/lib.sls' import firewall_enable with  context %}
{{ firewall_enable('logstash-syslog',2514,proto='tcp') }}
{{ firewall_enable('logstash-syslog',2514,proto='udp') }}
