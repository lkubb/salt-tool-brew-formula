# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as brew with context %}


Homebrew bin dir in global path is absent:
  file.replace:
    - name: /etc/paths
    - pattern: {{ brew.lookup.prefix | path_join("bin") | regex_escape }}\n
    - repl: ''
