{#
include:
  - .beaver

add safely on every log that you require to ship to aggregator
it will only be shipped if server have "shipper" role

#}

{% macro logship(appshort, logfile, type='daemon', tags=['daemon','error'], format='json', delimiter='\\\\n') -%}

{% if 'shipper' in grains['roles'] or 'aggregator' in grains['roles'] %}
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
{% endif %}

{%- endmacro %}
