# vim: ft=sls

{#-
    Installs Homebrew.

    This cannot easily use the official installer because, for noninteractive
    installation, it would need passwordless sudo on the admin user.

    On my (already set up) M1 system, the official installer issued the following commands:

    .. code-block:: bash

      /usr/bin/sudo /usr/sbin/chown -R `username`:admin /opt/homebrew
      /usr/bin/touch /Users/`username`/Library/Caches/Homebrew/.cleaned
      git init -q
      git config remote.origin.url `brew_mirror`
      git config remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
      git config core.autocrlf false
      git fetch --force origin
      git fetch --force --tags origin
      git reset --hard origin/master
      /opt/homebrew/bin/brew update --force --quiet
      git config --replace-all homebrew.analyticsmessage true
      git config --replace-all homebrew.caskanalyticsmessage true
#}

include:
  - .install
