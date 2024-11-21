# vim: ft=sls

{#-
    Sets global homebrew environment variables.

    These contain

    * most of the default settings issued by ``brew shellenv``
      (not those modifying ``$PATH``, ``$MANPATH`` and ``$INFOPATH``)
    * possible necessary variables when using custom remote mirrors
    * as well as custom environment vars passed in ``config``.

    Permanent $PATH modification can be achieved via the ``globalenv`` setting.
    Modifying $MANPATH, $INFOPATH and $fpath (for zsh) is left to the user.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as brew with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch %}


Homebrew global configuration is set:
  file.managed:
    - name: {{ brew.lookup.global_env }}
    - source: {{ files_switch(
                    ["brew.env", "brew.env.j2"],
                    lookup="Homebrew global configuration is set",
                    config=brew,
                 )
              }}
    - template: jinja
    - user: root
    - group: {{ brew.lookup.rootgroup }}
    - mode: '0644'
    - makedirs: true
    - context:
        brew: {{ brew | json }}
        config: {{ brew._vars | json }}

{%- set path = salt["environ.get"]("PATH") %}
{%- if brew.lookup.prefix | path_join("bin") not in path
    and not brew.get("globalpath") %}
{%-   set path = (brew.lookup.prefix | path_join("bin:")) ~ path %}

Homebrew is listed in $PATH during this salt run:
  environ.setenv:
    - name: PATH
    - value: '{{ path }}'
{%- endif %}
