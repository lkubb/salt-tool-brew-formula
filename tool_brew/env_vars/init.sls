# vim: ft=sls

{#-
    Sets environment variables for the running Salt minion process
    and persists them to user's ``persistenv`` files, if requested.

    The latter will contain

    * most of the default settings issued by ``brew shellenv``
      (not those modifying ``$PATH``, ``$MANPATH`` and ``$INFOPATH``)
    * possible necessary variables when using custom remote mirrors
    * as well as custom configured environment vars.

    They are parsed in ``tool_brew/post-map.jinja``.

    Modifying the paths is left to the user.
#}


{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as brew with context %}


Homebrew env vars are set during this salt run:
  environ.setenv:
    - value:
{%- for conf, val in brew._vars %}
        {{ conf | upper }}: '{{ val }}'
{%- endfor %}

{%- set path = salt["environ.get"]("PATH") %}
{%- if brew.lookup.prefix | path_join("bin") not in path
    and not brew.get("globalpath") %}
{%-   set path = brew.lookup.prefix ~ "/bin:" ~ path %}

Homebrew is listed in $PATH during this salt run:
  environ.setenv:
    - name: PATH
    - value: '{{ path }}'
{%- endif %}

{%- for user in brew.users | selectattr("persistenv", "defined") | selectattr("persistenv") %}

persistenv file for brew for user '{{ user.name }}' exists:
  file.managed:
    - name: {{ user.home | path_join(user.persistenv) }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - replace: false
    - mode: '0600'
    - dir_mode: '0700'
    - makedirs: true

{%-   for conf, val in brew._vars %}

brew env var '{{ conf | upper }}' is persisted for '{{ user.name }}':
  file.append:
    - name: {{ user.home | path_join(user.persistenv) }}
    - text: export {{ conf | upper }}="{{ val }}"
    - require:
      - persistenv file for brew for user '{{ user.name }}' exists
{%-   endfor %}
{%- endfor %}
