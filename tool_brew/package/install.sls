# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as brew with context %}
{%- set target = brew.lookup.prefix | path_join(brew.lookup.repodir) %}

include:
  - {{ tplroot }}.command_line_tools
  - {{ tplroot }}.env_vars


Homebrew parent directory has proper ownership:
  file.directory:
    - name: {{ brew.lookup.prefix }}
    - mode: '0755'
    - user: {{ brew.lookup.user if brew.lookup.m1 else "root" }}

Homebrew install path exists with correct permissions and ownership:
  file.directory:
    - name: {{ target }}
    - user: {{ brew.lookup.user }}
    - group: admin
    - mode: '0755'

Homebrew has been cloned once:
  cmd.run:
    - name: |
        git init -q
        git config remote.origin.url {{ brew.lookup.brew_mirror }}
        git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
        git config core.autocrlf false
        git fetch --force origin
        git fetch --force --tags origin
        git reset --hard origin/master
  # git.cloned:
  #   - name: {{ brew.lookup.brew_mirror }}
  #   - target: {{ target }}
    - cwd: {{ target }}
    - runas: {{ brew.lookup.user }}
    - unless:
        - cd '{{ target }}' && git status
    - require:
        - Command Line Tools are installed
        - Homebrew install path exists with correct permissions and ownership

Homebrew bin path exists with correct permissions and ownership:
  file.directory:
    - name: {{ brew.lookup.prefix | path_join("bin") }}
    - user: {{ brew.lookup.user }}
    - group: admin
    - mode: '0755'

Homebrew install path subdirs exist with correct permissions and ownership:
  file.directory:
    - name: {{ target }}
    - user: {{ brew.lookup.user }}
    - group: admin
    - recurse:
        - user
        - group

Homebrew executable is linked to bin dir:
  file.symlink:
    - name: {{ brew.lookup.prefix | path_join("bin", "brew") }}
    - target: {{ target | path_join("bin", "brew") }}
    - unless:
        # on M1 systems, prefix = target
        - test -x {{ brew.lookup.prefix | path_join("bin", "brew") }}

Homebrew cache is initialized:
  cmd.run:
    - name: {{ brew.lookup.prefix | path_join("bin", "brew") }} --cache
    - runas: {{ brew.lookup.user }}
    # only do that on the first run
    - onchanges:
        - Homebrew has been cloned once
    - require:
        - Homebrew env vars are set during this salt run

Homebrew is updated:
  cmd.run:
    - name: {{ brew.lookup.prefix | path_join("bin", "brew") }} update --force
    - env:
        - HOMEBREW_NO_ANALYTICS_THIS_RUN: '1'
        - HOMEBREW_NO_ANALYTICS_MESSAGE_OUTPUT: '1'
{%- if brew.lookup.brew_mirror != "https://github.com/Homebrew/brew.git" %}
        - HOMEBREW_BREW_GIT_REMOTE: '{{ brew.lookup.brew_mirror }}'
{%- endif %}
{%- if brew.lookup.core_mirror != "https://github.com/Homebrew/homebrew-core.git" %}
        - HOMEBREW_CORE_GIT_REMOTE: '{{ brew.lookup.core_mirror }}'
{%- endif %}
    - runas: {{ brew.lookup.user }}
    # only do that on the first run
    - onchanges:
        - Homebrew has been cloned once
    - require:
        - Homebrew env vars are set during this salt run
        - Homebrew cache is initialized

Homebrew setup is completed:
  test.nop:
    - name: Hooray, brew setup has finished successfully.
    - require:
        - Homebrew parent directory has proper ownership
        - Homebrew install path exists with correct permissions and ownership
        - Homebrew has been cloned once
        - Homebrew bin path exists with correct permissions and ownership
        - Homebrew install path subdirs exist with correct permissions and ownership
        - Homebrew executable is linked to bin dir
        - Homebrew is updated
