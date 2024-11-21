# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as brew with context %}


Homebrew global configuration is cleared:
  file.absent:
    - name: {{ brew.lookup.global_env }}
