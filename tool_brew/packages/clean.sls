# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as brew with context %}

include:
  - {{ tplroot }}.package


{%- if brew.get('packages') %}

Default packages are removed from brew:
  pkg.removed:
    - pkgs: {{ brew.packages | json }}
{%- endif %}
