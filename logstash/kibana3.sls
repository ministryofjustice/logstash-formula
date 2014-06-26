{% from "logstash/map.jinja" import kibana with context %}
{% from 'utils/apps/lib.sls' import app_skeleton with context %}

include:
  - nginx
  - .beaver

{{ app_skeleton('kibana') }}


kibana.git:
  git:
    - latest
    - name: https://github.com/elasticsearch/kibana.git
    - rev: {{ kibana.revision }}
    - target: /srv/kibana/application/{{ kibana.revision }}


/srv/kibana/application/current:
  file:
    - symlink
    - target: /srv/kibana/application/{{ kibana.revision }}
    - makedirs: True
    - watch:
      - git: kibana.git


# configure it only if hosted on separate host than elastic search

/srv/kibana/application/current/src/config.js:
  file:
    - managed
    - source: salt://logstash/templates/kibana/config.js
    - user: root
    - group: root
    - mode: 644 
    - template: jinja
    - require:
      - user: kibana

/etc/nginx/conf.d/kibana.conf:
  file:
    - managed
    - source: salt://nginx/templates/vhost-static.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - watch_in:
      - service: nginx
    - require:
      - user: kibana
    - context:
      appslug: kibana
      is_default: False
      server_name: 'kibana.*'
      root_dir: /srv/kibana/application/current/src
      index: False
    - watch_in:
      - service: nginx

# Elastic search proxy for kibana
/etc/nginx/conf.d/elasticsearch.conf:
  file:
    - managed
    - source: salt://logstash/templates/vhost-elasticsearch-proxy.conf
    - user: root
    - group: root
    - mode: 644 
    - template: jinja
    - watch_in:
      - service: nginx
    - context:
      appslug: elasticsearch
      is_default: False
      server_name: 'elasticsearch.*'
      proxy_host: http://localhost
      proxy_port: 9200
    - watch_in:
      - service: nginx

/etc/apparmor.d/nginx_local/kibana:
  file.managed:
    - source: salt://logstash/templates/kibana/kibana_apparmor_profile
    - template: jinja
    - watch_in:
      - service: nginx

{% from 'logstash/lib.sls' import logship with context %}
{{ logship('kibana-access', '/var/log/nginx/kibana.access.json', 'nginx', ['nginx','kibana','access'], 'rawjson') }}
{{ logship('kibana-error',  '/var/log/nginx/kibana.error.log', 'nginx', ['nginx','kibana','error'], 'json') }}
