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
    - dist: trusty
    - file: /etc/apt/sources.list.d/logstash.list
    - keyid: D88E42B4
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: logstash


logstash:
  pkg.installed:
    - require:
      - pkgrepo: logstash_repo
  
logstash:
  service.running:
    - enable: True
    - require:
      - pkg: logstash
    - watch:
      - file: /etc/logstash/conf.d/indexer.conf
      - file: /etc/default/logstash
      - file: /etc/init/logstash.conf
      - file: /usr/src/packages/{{logstash.source.file}}
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
      - pkg: logstash


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
      - pkg: logstash
    - require_in: 
      - service: logstash


{% from 'firewall/lib.sls' import firewall_enable with  context %}
{{ firewall_enable('logstash-syslog',2514,proto='tcp') }}
{{ firewall_enable('logstash-syslog',2514,proto='udp') }}
