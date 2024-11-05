# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``tool_brew`` meta-state
    in reverse order.
#}

include:
  - .gnu.clean
  - .env_vars.clean
  - .globalpath.clean
  - .package.clean
