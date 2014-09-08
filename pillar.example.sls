autofs:
  package:
    upgrade: False
  service:
    manage: False
    enable: True
  config:
    manage: False
    template: salt://autofs/conf/mounts
    require:
      - nfs
    mounts:
      - backups
      - staff
      - network
  lookup:
    package: autofs
    service: autofs
    config: /etc/auto.master
