# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as brew with context %}
{%- set brew_bin = brew.lookup.prefix | path_join('bin', 'brew') %}

include:
  - {{ tplroot }}.env_vars

{%- for tap in brew._taps %}
{%-   if tap not in brew.lookup.official_taps %}

Homebrew tap '{{ tap.name }}' is unavailable:
  cmd.run:
    - name: {{ brew_bin }} untap '{{ tap.name }}'
    - runas: {{ brew.lookup.user }}
    # there is no unless_any to mean "unless any is true".
    # unless is evaluated to mean "unless all are true"
    # unless_any workaround
    - onlyif:
      - sudo -u '{{ brew.lookup.user }}' {{ brew_bin }} tap | grep '{{ tap.name }}'
    - require:
        - Homebrew env vars are set during this salt run

{%-   else %}

Homebrew official tap '{{ tap.name }}' is reset to default:
  cmd.run:
    - name: {{ brew_bin }} untap '{{ tap.name }}' && {{ brew_bin }} tap '{{ tap.name }}'
{%-   endif %}
{%- endfor %}
