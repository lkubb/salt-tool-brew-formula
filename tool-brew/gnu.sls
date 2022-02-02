{%- from 'tool-brew/map.jinja' import brew -%}

{#- not sure how to handle /../ tbh -#}
{%- set gnupath = '/'.join(brew._prefix.split('/')[:-1]) ~ '/gnubin' %}

GNU tool folder exists:
  file.directory:
    - name: {{ gnupath }}
    - user: {{ brew._user }}
    - group: admin
    - mode: 0755

GNU tools are linked unprefixed:
  cmd.run:
    - name: |
        for gnuutil in {{ brew._prefix }}/**/libexec/gnubin/*; do
          ln -sf "$gnuutil" {{ gnupath }}/
        done
    - runas: {{ brew._user }}
    - onlyif:
        - stat -t {{ brew._prefix }}/**/libexec/gnubin/* &>/dev/null
    - shell: /bin/zsh
    - require:
        - GNU tool folder exists
