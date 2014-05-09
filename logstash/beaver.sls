include:
  - python


beaver:
  pip.installed:
    - require:
      - pkg: python-pip
  service.running:
    - require:
      - pip: beaver
      - watch:
        - file: /etc/init/beaver.conf
        - file: /etc/beaver.conf


/etc/supervisor.d/beaver.conf:
  file.absent

/etc/beaver.conf:
  file:
    - managed
    - source: salt://logstash/templates/beaver/beaver.conf
    - template: jinja


/etc/beaver.d:
  file:
    - directory

/etc/init/beaver.conf:
  file.managed:
    - source: salt://logstash/templates/beaver/upstart-beaver.conf
    - template: jinja
