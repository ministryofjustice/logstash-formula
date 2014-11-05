{% from "logstash/map.jinja" import logstash with context %}

include:
  - .deps
  - java
  - redis
  - firewall

stop_old_logstash:
  service.dead:
    - name: logstash-indexer

remove_old_logstash_upstart_conf:
  file.absent:
    - name: /etc/init/logstash-indexer.conf
    - prereq:
      - service: stop_old_logstash

remove_old_logstash_jar:
  file.absent:
    - name: /usr/src/packages/logstash-1.2.2-flatjar.jar

remove_old_logstash_indexer_conf:
  file.absent:
    - name: /etc/logstash/indexer.conf

logstash_repo:
  pkgrepo.managed:
    - humanname: Logstash PPA
    - name: deb http://packages.elasticsearch.org/logstash/1.4/debian stable main
    - file: /etc/apt/sources.list.d/logstash.list
    - keyid: D88E42B4
    - keyserver: keyserver.ubuntu.com
    - requires:
      - service: stop_old_logstash

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
      - file: /etc/logstash/patterns

/var/log/logstash:
  file.directory:
    - template: jinja
    - dir_mode: 2750
    - user: logstash
    - group: adm
    - require:
      - pkg: logstash_indexer

/var/log/logstash/archive:
  file.directory:
    - template: jinja
    - dir_mode: 2750
    - user: logstash
    - group: adm
    - require:
      - file: /var/log/logstash/archive

/etc/logstash/patterns:
  file:
    - recurse
    - clean: True
    - source: salt://logstash/templates/logstash/patterns
    - template: jinja
    - file_mode: 644
    - dir_mode: 2755
    - user: root
    - group: logstash
    - require:
      - pkg: logstash_indexer

/etc/logstash/conf.d:
  file.directory:
    - clean: True
    - dir_mode: 2755
    - user: root
    - group: logstash
    - require:
      - pkg: logstash_indexer

{% for conf_file in logstash.config_files %}

/etc/logstash/conf.d/{{ conf_file }}:
  file:
    - managed
    - source: salt://logstash/templates/logstash/conf.d/{{ conf_file }}
    - template: jinja
    - mode: 644
    - user: root
    - group: logstash
    - mode: 644
    - require:
      - pkg: logstash_indexer
      - file: /etc/logstash/conf.d
    - watch_in:
      - service: logstash_indexer

{% endfor %}


{% from 'firewall/lib.sls' import firewall_enable with  context %}
{{ firewall_enable('logstash-syslog',2514,proto='tcp') }}
{{ firewall_enable('logstash-syslog',2514,proto='udp') }}
