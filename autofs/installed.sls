{% from "autofs/map.jinja" import autofs with context %}

{% set package = {
    'name': autofs.package,
    'upgrade': salt['pillar.get']('autofs:package:upgrade', False),
} %}

{% set service = {
    'name': autofs.service,
    'manage': salt['pillar.get']('autofs:service:manage', False), 
    'enable': salt['pillar.get']('autofs:service:enable', True), 
} %}

{% set config = {
    'manage': salt['pillar.get']('autofs:config:manage', False), 
    'autofsconfig': autofs.config,
    'saltconfig': '/etc/auto.salt',
    'template': salt['pillar.get']('autofs:config:template', 'salt://autofs/conf/auto.salt'), 
    'require': salt['pillar.get']('autofs:config:require', []), 
    'mountpoints': salt['pillar.get']('autofs:config:mounts', []), 
} %}

autofs.installed:
  require:
    - sls: autofs.pkg
{% if service.manage %}
    - sls: autofs.service
{% endif %}
{% if config.manage %}
    - sls: autofs.config
{% endif %}
{% if config.require %}
  {% for sls in config.require %}
    - sls: {{ sls }}
  {% endfor %}
{% endif %}

autofs.pkg:
  pkg.{{ 'latest' if package.upgrade else 'installed' }}:
    - name: {{ package.name }}

{% if service.manage %}
autofs.service:
  service.{{ 'running' if service.enable else 'dead' }}:
    - name: {{ service.name }}
  require:
    - pkg: autofs.installed
  {% if config.manage %}
    - sls: autofs.config
  watch:
    - file: autofs.config
    - pkg: autofs.pkg
  {% endif %}
{% endif %}

{% if config.manage %}
autofs.config:
  file.append:
    - name: {{ config.autofsconfig }}
    - text:
      - "# Include SaltStack map"
      - "/-  {{ config.saltconfig }}"
  require:
    - sls: autofs.map
{%- for mountname in config.mountpoints -%}
  {%- set mount = {
    'path': salt['pillar.get']('autofs:config:mounts:' ~ mountname ~ ':path', ''), 
    'options': salt['pillar.get']('autofs:config:mounts:' ~ mountname  ~ ':options', ''), 
    'target': salt['pillar.get']('autofs:config:mounts:' ~ mountname  ~ ':target', ''), 
  } -%}
  {%- if mount.path and mount.target %}
    - sls: autofs.path.{{ mount.path }}
  {%- endif -%}
{%- endfor %}

autofs.map:
  file.managed:
    - name: {{ config.saltconfig }}
    - source: {{ config.template }}
    - template: jinja
    - user: root
    - group: root

{%- for mountname in config.mountpoints -%}
  {%- set mount = {
    'path': salt['pillar.get']('autofs:config:mounts:' ~ mountname ~ ':path', ''), 
    'options': salt['pillar.get']('autofs:config:mounts:' ~ mountname  ~ ':options', ''), 
    'target': salt['pillar.get']('autofs:config:mounts:' ~ mountname  ~ ':target', ''), 
  } -%}
  {%- if mount.path and mount.target %}
autofs.path.{{ mount.path }}: 
  file.directory:
    - name: {{ mount.path }}
    - user: root
    - group: root
    - makedirs: True
  {%- endif -%}
{%- endfor -%}
{% endif %}
