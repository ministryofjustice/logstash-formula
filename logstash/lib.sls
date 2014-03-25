{#
include:
  - .beaver

#}

{% macro logship(appshort, logfile, type='daemon', tags=['daemon','error'], format='json', delimiter='\\\\n') -%}

{% set tags = ','.join(tags) %}

/etc/beaver.d/{{appshort}}.conf:
  file:
    - managed
    - source: salt://logging/templates/beaver/beaver-file.conf
    - template: jinja
    - context:
      logfile: {{logfile}}
      format: {{format}}
      type: {{type}}
      tags: {{tags}}
      delimiter: "{{delimiter}}"
    - watch_in:
      - supervisord: supervise-beaver

{%- endmacro %}
