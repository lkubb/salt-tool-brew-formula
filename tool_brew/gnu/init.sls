{#-
    Creates a special directory that contains unprefixed symlinks
    to GNU versions of tools (e.g. ``awk`` instead of ``gawk``).

    This can be used to replace the BSD variants found in MacOS by default.
-#}


{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as brew with context %}


GNU tool folder exists:
  file.directory:
    - name: {{ brew.lookup.gnupath }}
    - user: {{ brew.lookup.user }}
    - group: admin
    - mode: '0755'

GNU tools are linked unprefixed:
  cmd.run:
    - name: |
        for gnuutil in {{ brew.lookup.prefix }}/**/libexec/gnubin/*; do
          ln -sf "$gnuutil" {{ brew.lookup.gnupath }}/
        done
    - runas: {{ brew.lookup.user }}
    - onlyif:
        - stat -t {{ brew.lookup.prefix }}/**/libexec/gnubin/* &>/dev/null
    - shell: /bin/zsh
    - require:
        - GNU tool folder exists

# vim: ft=sls
