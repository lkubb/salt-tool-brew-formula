Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``tool_brew``
~~~~~~~~~~~~~
*Meta-state*.

Performs all operations described in this formula according to the specified configuration.


``tool_brew.package``
~~~~~~~~~~~~~~~~~~~~~
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


``tool_brew.globalpath``
~~~~~~~~~~~~~~~~~~~~~~~~
Ensures brew bin dir is globally in/absent from ``$PATH``.

This is achieved by appending it to/removing it from ``/etc/paths``.


``tool_brew.env_vars``
~~~~~~~~~~~~~~~~~~~~~~
Sets environment variables for the running Salt minion process
and persists them to user's ``persistenv`` files, if requested.

The latter will contain

* most of the default settings issued by ``brew shellenv``
  (not those modifying ``$PATH``, ``$MANPATH`` and ``$INFOPATH``)
* possible necessary variables when using custom remote mirrors
* as well as custom configured environment vars.

They are parsed in ``tool_brew/post-map.jinja``.

Modifying the paths is left to the user.


``tool_brew.taps``
~~~~~~~~~~~~~~~~~~
Manages Homebrew taps. This allows to

* add custom taps, either on Github or elsewhere and
* replace default taps (e.g. `homebrew/cask`) with custom mirrors.


``tool_brew.packages``
~~~~~~~~~~~~~~~~~~~~~~



``tool_brew.gnu``
~~~~~~~~~~~~~~~~~
Creates a special directory that contains unprefixed symlinks
to GNU versions of tools (e.g. ``awk`` instead of ``gawk``).

This can be used to replace the BSD variants found in MacOS by default.


``tool_brew.command_line_tools``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_brew.clean``
~~~~~~~~~~~~~~~~~~~
*Meta-state*.

Undoes everything performed in the ``tool_brew`` meta-state
in reverse order.


``tool_brew.package.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~
Removes Homebrew.

   On systems where the prefix is not the installation dir,
   which is the case on x86_64 Macs by default, this will first
   uninstall all regular packages to not leave stuff behind
   (eg in `/usr/local/bin`).


``tool_brew.globalpath.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_brew.env_vars.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_brew.taps.clean``
~~~~~~~~~~~~~~~~~~~~~~~~



``tool_brew.packages.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_brew.gnu.clean``
~~~~~~~~~~~~~~~~~~~~~~~



