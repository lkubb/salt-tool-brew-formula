.. _readme:

Homebrew Formula
================

Manages Homebrew.

.. contents:: **Table of Contents**
   :depth: 1

Usage
-----
Applying ``tool_brew`` will make sure ``brew`` is configured as specified.

Configuration
-------------

This formula
~~~~~~~~~~~~
The general configuration structure is in line with all other formulae from the `tool` suite, for details see :ref:`toolsuite`. An example pillar is provided, see :ref:`pillar.example`. Note that you do not need to specify everything by pillar. Often, it's much easier and less resource-heavy to use the ``parameters/<grain>/<value>.yaml`` files for non-sensitive settings. The underlying logic is explained in :ref:`map.jinja`.

User-specific
^^^^^^^^^^^^^
The following shows an example of ``tool_brew`` per-user configuration. If provided by pillar, namespace it to ``tool_global:users`` and/or ``tool_brew:users``. For the ``parameters`` YAML file variant, it needs to be nested under a ``values`` parent key. The YAML files are expected to be found in

1. ``salt://tool_brew/parameters/<grain>/<value>.yaml`` or
2. ``salt://tool_global/parameters/<grain>/<value>.yaml``.

.. code-block:: yaml

  user:

      # Persist environment variables used by this formula for this
      # user to this file (will be appended to a file relative to $HOME)
    persistenv: '.config/zsh/zshenv'

      # Add runcom hooks specific to this formula to this file
      # for this user (will be appended to a file relative to $HOME)
    rchook: '.config/zsh/zshrc'

Formula-specific
^^^^^^^^^^^^^^^^

.. code-block:: yaml

  tool_brew:
      # Specify global configuration env vars.
    config:
      - HOMEBREW_NO_ANALYTICS
      - HOMEBREW_NO_INSECURE_REDIRECT
      - HOMEBREW_CASK_OPTS:
          - --require-sha
          - --no-quarantine
      # Ensure brew bin dir is globally in/absent from `$PATH`.
    globalpath: true
      # When initially installing brew, use this version. Defaults to latest.
    init_version: null
      # Helper to automatically install packages.
    packages:
      - git
      - gpg
      - wget
    taps:
        # List of taps that should not be available.
      absent:
        - unwanted/tap
        # By default, taps not hosted on Github are not updated automatically
        # (for performance reasons). Force automatic updates for taps managed
        # with this formula, either by default or only for specific ones.
        # This formula forces autoupdate for mirrors of offical taps automatically.
      autoupdate:
        default: false
        my/customtap: true
        # Force override of existing remotes with specified ones
        # (not necessary for mirrors of official taps).
      forced: false
        # homebrew-cask* mirrors and custom taps go here:
      wanted:
            # If you specify the name of an official tap, the remote will be matched.
            # If you specify the name of an existing non-official tap and
            #   taps_forced is set to true, the remote will be matched.
        - homebrew/cask: https://mygit.example.com/my/homebrew-cask
            # brew tap short syntax works as well
            # (mapped to github.com/<first>/homebrew-<second>)
        - blacktop/tap
        - my/customtap: https://mygit.example.com/my/custom-tap


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
Installs Homebrew using the official package.


``tool_brew.globalpath``
~~~~~~~~~~~~~~~~~~~~~~~~
Ensures brew bin dir is globally in/absent from ``$PATH``.

This is achieved by appending it to/removing it from ``/etc/paths``.


``tool_brew.env_vars``
~~~~~~~~~~~~~~~~~~~~~~
Sets global homebrew environment variables.

These contain

* most of the default settings issued by ``brew shellenv``
  (not those modifying ``$PATH``, ``$MANPATH`` and ``$INFOPATH``)
* possible necessary variables when using custom remote mirrors
* as well as custom environment vars passed in ``config``.

Permanent $PATH modification can be achieved via the ``globalenv`` setting.
Modifying $MANPATH, $INFOPATH and $fpath (for zsh) is left to the user.


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




Development
-----------

Contributing to this repo
~~~~~~~~~~~~~~~~~~~~~~~~~

Commit messages
^^^^^^^^^^^^^^^

Commit message formatting is significant.

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

pre-commit
^^^^^^^^^^

`pre-commit <https://pre-commit.com/>`_ is configured for this formula, which you may optionally use to ease the steps involved in submitting your changes.
First install  the ``pre-commit`` package manager using the appropriate `method <https://pre-commit.com/#installation>`_, then run ``bin/install-hooks`` and
now ``pre-commit`` will run automatically on each ``git commit``.

.. code-block:: console

  $ bin/install-hooks
  pre-commit installed at .git/hooks/pre-commit
  pre-commit installed at .git/hooks/commit-msg

State documentation
~~~~~~~~~~~~~~~~~~~
There is a script that semi-autodocuments available states: ``bin/slsdoc``.

If a ``.sls`` file begins with a Jinja comment, it will dump that into the docs. It can be configured differently depending on the formula. See the script source code for details currently.

This means if you feel a state should be documented, make sure to write a comment explaining it.
