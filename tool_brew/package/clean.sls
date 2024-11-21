# vim: ft=sls

{#- Removes Homebrew.

    On systems where the prefix is not the installation dir,
    which is the case on x86_64 Macs by default, this will first
    uninstall all regular packages to not leave stuff behind
    (eg in `/usr/local/bin`).
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as brew with context %}
{%- set target = brew.lookup.prefix | path_join(brew.lookup.repodir) %}

include:
  - {{ tplroot }}.env_vars.clean
  - {{ tplroot }}.globalpath.clean
  - {{ tplroot }}.gnu.clean


{%- if target != brew.lookup.prefix %}

All homebrew formulae are removed (casks are exempt):
  cmd.run:
    - name: brew list --formula | xargs brew uninstall --force
    - env:
{%-   for conf, val in brew._vars %}
        - {{ conf | upper }}: '{{ val }}'
{%-   endfor %}
    - require_in:
      - Homebrew is removed
{%- endif %}

Homebrew is removed:
  file.absent:
    - names:
      - {{ target }}
      - {{ salt["user.info"](brew.lookup.user).home | path_join("Library", "Caches", "Homebrew") }}
