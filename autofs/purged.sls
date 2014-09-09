{% from "autofs/map.jinja" import autofs with context %}

{% set package = {
    'name': autofs.package,
} %}

{% set config = {
    'manage': salt['pillar.get']('autofs:config:manage', False), 
    'saltconfig': '/etc/auto.salt',
    'mountpoints': salt['pillar.get']('autofs:config:mounts', []), 
} %}

autofs.purged:
  pkg.purged:
    - name: {{ package.name }}
  file.absent:
    - name: {{ config.saltconfig }}
{% if config.manage %}
{%- for mountname in config.mountpoints -%}
  {%- set mount = {
    'path': salt['pillar.get']('autofs:config:mounts:' ~ mountname ~ ':path', ''), 
    'options': salt['pillar.get']('autofs:config:mounts:' ~ mountname  ~ ':options', ''), 
    'target': salt['pillar.get']('autofs:config:mounts:' ~ mountname  ~ ':target', ''), 
  } -%}
  {%- if mount.path and mount.target %}
    - sls: autofs.path.purged.:{{ mount.path }}
  {%- endif -%}
{%- endfor %}

{%- for mountname in config.mountpoints -%}
  {%- set mount = {
    'path': salt['pillar.get']('autofs:config:mounts:' ~ mountname ~ ':path', ''), 
    'options': salt['pillar.get']('autofs:config:mounts:' ~ mountname  ~ ':options', ''), 
    'target': salt['pillar.get']('autofs:config:mounts:' ~ mountname  ~ ':target', ''), 
  } -%}
  {%- if mount.path and mount.target %}
autofs.path.purged.{{ mount.path }}: 
  file.absent:
    - name: {{ mount.path }}
  {%- endif -%}
{%- endfor -%}
{% endif %}
