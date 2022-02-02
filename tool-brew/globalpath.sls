{%- from 'tool-brew/map.jinja' import brew -%}

include:
  - .package

{%- set active = brew.get('globalpath', False) %}

# this is useful on M1 macs for initial bootstrap at least
Homebrew bin dir in global path is managed:
  file.{{ 'prepend' if active else 'replace' }}:
    - name: /etc/paths
  {%- if active %}
    - text: {{ brew._prefix }}/bin
    - require:
        - Homebrew setup is completed
  {%- else %}
    - pattern: {{ brew._prefix ~ '/bin' | regex_escape}}\n
    - repl: ''
  {%- endif %}
