{% from "aws/map.jinja" import aws with context %}
stunnel_scanner_cron:
  pkg.installed:
    - name: cron
  service.running:
    - name: cron

stunnel_scanner.py:
  file.managed:
    - name: /usr/local/bin/stunnel_scanner.py
    - source: salt://logstash/files/stunnel_scanner.py
    - user: root
    - group: root
    - mode: 755
    - template: jinja

cron_cleanup_stunnel_scanner:
  cmd.run:
    - name: crontab -l | grep -v 'stunnel_scanner.py'  | crontab -
    - require_in:
      - state: cron_stunnel_scanner

cron_stunnel_scanner:
  cron.present:
    - name: |
        python /usr/local/bin/stunnel_scanner.py
         --log-file /var/log/cron.log
    - user: root
    - minute: '*/60'
