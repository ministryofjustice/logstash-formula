{#
include:
  - .beaver

#}

{% macro logship(appshort, logfile, type='daemon', tags=['daemon','error'], format='json', delimiter='\\\\n', absent=False) -%}
{% if salt['pillar.get']('monitoring:enabled', True) and absent == false %}

{% set tags = ','.join(tags) %}

/etc/beaver.d/{{appshort}}.conf:
  file:
    - managed
    - source: salt://logstash/templates/beaver/beaver-file.conf
    - template: jinja
    - context:
      logfile: {{logfile}}
      format: {{format}}
      type: {{type}}
      tags: {{tags}}
      delimiter: "{{delimiter}}"
    - watch_in:
      - service: beaver
    - require:
      - file: /etc/beaver.d

{% endif %}

{% if absent == True %}
/etc/beaver.d/{{appshort}}.conf:
  file.absent
{% endif %}

{%- endmacro %}
