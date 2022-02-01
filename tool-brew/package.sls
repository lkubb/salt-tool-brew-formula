{#- Installs Homebrew.

    This cannot easily use the official installer because, for noninteractive
    installation, it would need passwordless sudo on the admin user.

    On my (already set up) system, the installer issued the following commands::

        /usr/bin/sudo /usr/sbin/chown -R jeanluc:admin /opt/homebrew
        /usr/bin/touch /Users/jeanluc/Library/Caches/Homebrew/.cleaned
        git init -q
        git config remote.origin.url https://git.jean.casa/Github/brew
        git config remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
        git config core.autocrlf false
        git fetch --force origin
        git fetch --force --tags origin
        git reset --hard origin/master
        /opt/homebrew/bin/brew update --force --quiet
        git config --replace-all homebrew.analyticsmessage true
        git config --replace-all homebrew.caskanalyticsmessage true
-#}

{%- from 'tool-brew/map.jinja' import brew -%}

include:
  - .command_line_tools
  - .env

Homebrew parent directory has proper ownership:
  file.directory:
    - name: {{ brew._prefix }}
    - mode: '0755'
    - user: {{ brew._user if brew._m1 else 'root'}}

Homebrew install path exists with correct permissions and ownership:
  file.directory:
    - name: {{ brew._target }}
    - user: {{ brew._user }}
    - group: admin
    - mode: '0755'

Homebrew has been cloned once:
  cmd.run:
    - name: |
        cd {{ brew._target }}
        git init -q
        git config remote.origin.url {{ brew.get('mirror_brew', 'https://github.com/Homebrew/brew.git') }}
        git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
        git config core.autocrlf false
        git fetch --force origin
        git fetch --force --tags origin
        git reset --hard origin/master
  # git.cloned:
  #   - name: {{ brew.get('mirror_brew', 'https://github.com/Homebrew/brew.git') }}
  #   - target: {{ brew._target }}
    - runas: {{ brew._user }}
    - unless:
        - cd {{ brew._target }} && git status
    - require:
        - Command Line Tools are installed
        - Homebrew install path exists with correct permissions and ownership

Homebrew bin path exists with correct permissions and ownership:
  file.directory:
    - name: {{ brew._prefix }}/bin
    - user: {{ brew._user }}
    - group: admin
    - mode: '0755'

Homebrew install path subdirs exist with correct permissions and ownership:
  file.directory:
    - name: {{ brew._target }}
    - user: {{ brew._user }}
    - group: admin
    - recurse:
        - user
        - group

Homebrew executable is linked to bin dir:
  file.symlink:
    - name: {{ brew._prefix }}/bin/brew
    - target: {{ brew._target }}/bin/brew
    - unless:
        # on M1 systems, prefix = target
        - test -x {{ brew._prefix }}/bin/brew

Homebrew cache is initialized:
  cmd.run:
    - name: {{ brew._prefix }}/bin/brew --cache
    - runas: {{ brew._user }}
    # only do that on the first run
    - onchanges:
        - Homebrew has been cloned once
    - require:
        - Homebrew env vars are set during this salt run

Homebrew is updated:
  cmd.run:
    - name: {{ brew._prefix }}/bin/brew update --force
    - env:
        - HOMEBREW_NO_ANALYTICS_THIS_RUN: '1'
        - HOMEBREW_NO_ANALYTICS_MESSAGE_OUTPUT: '1'
{%- if brew.get('mirror_brew') %}
        - HOMEBREW_BREW_GIT_REMOTE: '{{ brew.mirror_brew }}'
{%- endif %}
{%- if brew.get('mirror_core') %}
        - HOMEBREW_CORE_GIT_REMOTE: '{{ brew.mirror_core }}'
{%- endif %}
    - runas: {{ brew._user }}
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
