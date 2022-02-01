{%- from 'tool-brew/map.jinja' import brew -%}

GNU tools are linked unprefixed to /usr/local/gnubin/*:
  cmd.run:
    - name: |
        for gnuutil in {{ brew._prefix }}/**/libexec/gnubin/*; do
          ln -s $gnuutil /usr/local/gnubin/
        done
    - runas: {{ brew._user }}
    - onlyif:
        - stat -t {{ brew._prefix }}/**/libexec/gnubin/* &>/dev/null
    - shell: /bin/zsh
