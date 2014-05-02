include:
  - python


beaver:
  pip.installed:
    - require:
      - pkg: python-pip
  service:
    - require:
      - pip: beaver
      - file: /etc/init/beaver.conf


/etc/beaver.conf:
  file:
    - managed
    - source: salt://logstash/templates/beaver/beaver.conf
    - template: jinja
    - watch_in:
      - service: beaver


/etc/beaver.d:
  file:
    - directory

/etc/init/beaver.conf:
  file.managed:
    - source: salt://logstash/templates/beaver/upstart-beaver.conf
    - template: jinja
