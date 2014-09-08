{% from "autofs/map.jinja" import autofs with context %}

{% set package = {
    'name': autofs.package,
} %}

{% set config = {
    'saltconfig': '/etc/auto.salt',
} %}

autofs.purged:
  pkg.purged:
    - name: {{ package.name }}
  file.absent:
    - name: {{ config.saltconfig }}
