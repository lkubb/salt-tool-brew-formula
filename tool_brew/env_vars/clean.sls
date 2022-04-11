# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as brew with context %}


{%-   for conf, val in brew._vars %}

brew env var '{{ conf | upper }}' is not persisted for '{{ user.name }}':
  file.replace:
    - name: {{ user.home | path_join(user.persistenv) }}
    - pattern: {{ 'export {}="{}"\n'.format(conf | upper, val) | regex_escape }}
    - repl: ''
{%-   endfor %}
{%- endfor %}
