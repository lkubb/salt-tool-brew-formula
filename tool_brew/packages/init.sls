# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as brew with context %}

include:
  - {{ tplroot }}.package


{%- if brew.get('packages') %}

Default packages are installed with brew:
  pkg.installed:
    - pkgs: {{ brew.packages | json }}
    - require:
        - Homebrew setup is completed
{%- endif %}
