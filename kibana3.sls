{% set kibana_rev='v3.0.0milestone4' %}
{% from 'utils/apps/lib.sls' import app_skeleton with context %}

include:
  - nginx
  - .beaver

{{ app_skeleton('kibana') }}


kibana.git:
  git:
    - latest
    - name: https://github.com/elasticsearch/kibana.git
    - rev: {{ kibana_rev }}
    - target: /srv/kibana/application/{{ kibana_rev }}


/srv/kibana/application/current:
  file:
    - symlink
    - target: /srv/kibana/application/{{ kibana_rev }}
    - makedirs: True
    - watch:
      - git: kibana.git


#configure it only if hosted on separate host than elastic search


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
      service_name: kibana
      is_default: False
      server_name: 'kibana.*'
      root_dir: /srv/kibana/application/current/src
      index: False
    - watch_in:
      - service: nginx


{% from 'logging/lib.sls' import logship with context %}
{{ logship('kibana-access', '/var/log/nginx/kibana.access.json', 'nginx', ['nginx','kibana','access'], 'rawjson') }}
{{ logship('kibana-error',  '/var/log/nginx/kibana.error.log', 'nginx', ['nginx','kibana','error'], 'json') }}
