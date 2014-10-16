{% from "logstash/map.jinja" import logstash with context %}
{% from 'utils/apps/lib.sls' import app_skeleton with context %}

include:
  - .deps
  - java
  - redis
  - firewall

{{ app_skeleton('logstash') }}

logstash_repo:
  pkgrepo.managed:
    - humanname: Logstash PPA
    - name: deb http://packages.elasticsearch.org/logstash/1.4/debian stable main
    - file: /etc/apt/sources.list.d/logstash.list
    - keyid: D88E42B4
    - keyserver: keyserver.ubuntu.com


logstash_indexer:
  pkg.installed:
    - name: logstash
    - require:
      - pkgrepo: logstash_repo
  service.running:
    - enable: True
    - name: logstash
    - require:
      - pkg: logstash_indexer
    - watch:
      - file: /etc/logstash/conf.d/indexer.conf
      - file: /etc/logstash/patterns



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
      - pkg: logstash_indexer


/etc/logstash/conf.d/indexer.conf:
  file:
    - managed
    - source: salt://logstash/templates/logstash/indexer.conf
    - template: jinja
    - mode: 644
    - user: logstash
    - group: logstash
    - mode: 644
    - require:
      - pkg: logstash_indexer
    - require_in: 
      - service: logstash_indexer


{% from 'firewall/lib.sls' import firewall_enable with  context %}
{{ firewall_enable('logstash-syslog',2514,proto='tcp') }}
{{ firewall_enable('logstash-syslog',2514,proto='udp') }}
