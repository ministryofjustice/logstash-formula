include:
  - bootstrap.directories
  - python
  - supervisor


beaver:
  pip:
    - installed
    - require:
      - pkg: python-pip


/etc/beaver.conf:
  file:
    - managed
    - source: salt://logstash/templates/beaver/beaver.conf
    - template: jinja
    - watch_in:
      - supervisord: supervise-beaver


/etc/beaver.d:
  file:
    - directory


{% from 'supervisor/lib.sls' import supervise with context %}
{{ supervise("beaver",
             user="root",
             cmd="/usr/local/bin/beaver",
             args="-c /etc/beaver.conf -C /etc/beaver.d -t redis",
             numprocs=1,
             log_dir="/var/log",
             working_dir="/",
             supervise=True) }}
