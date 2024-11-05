# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as brew with context %}


GNU tool folder is absent:
  file.absent:
    - name: {{ brew.lookup.gnupath }}
