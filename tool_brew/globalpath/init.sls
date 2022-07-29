{#-
    Ensures brew bin dir is globally in/absent from ``$PATH``.

    This is achieved by appending it to/removing it from ``/etc/paths``.
-#}

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as brew with context %}

include:
  - {{ tplroot }}.package


{%- set active = brew.get('globalpath', false) %}

# this is useful on M1 macs for initial bootstrap at least
Homebrew bin dir in global path is managed:
  file.{{ 'prepend' if active else 'replace' }}:
    - name: /etc/paths
{%- if active %}
    - text: {{ brew.lookup.prefix | path_join('bin') }}
    - require:
        - Homebrew setup is completed
{%- else %}
    - pattern: {{ brew.lookup.prefix | path_join('bin') | regex_escape }}\n
    - repl: ''
{%- endif %}

# vim: ft=sls
