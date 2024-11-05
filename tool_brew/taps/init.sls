# vim: ft=sls

{#-
    Manages Homebrew taps. This allows to

    * add custom taps, either on Github or elsewhere and
    * replace default taps (e.g. `homebrew/cask`) with custom mirrors.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as brew with context %}
{%- set brew_bin = brew.lookup.prefix | path_join("bin", "brew") %}

include:
  - {{ tplroot }}.package
  - {{ tplroot }}.env_vars

{%- for tap in brew._taps %}
  {%- set tap_dir = brew.lookup.prefix | path_join("Library", "Taps", tap.name.split("/")[0], "homebrew-" ~ tap.name.split("/")[1]) %}

Homebrew tap '{{ tap.name }}' is available:
  cmd.run:
    - name: {{ brew_bin }} tap '{{ tap.name }}'{% if tap.remote %} '{{ tap.remote }}'{% endif %}
    - runas: {{ brew.lookup.user }}
    # there is no unless_any to mean "unless any is true".
    # unless is evaluated to mean "unless all are true"
    # unless_any workaround
    - unless:
        - |
            sudo -u '{{ brew.lookup.user }}' {{ brew_bin }} tap | grep '{{ tap.name }}' \
            || {{ tap.name in brew.lookup.official_taps }}
    - require:
        - Homebrew setup is completed
        - Homebrew env vars are set during this salt run

{%-   if tap.remote %}

Homebrew tap '{{ tap.name }}' is force-set to custom remote:
  cmd.run:
    - name: |
        {{ brew_bin }} tap \
{%-     if tap.autoupdate %}
        --force-auto-update \
{%-     endif %}
        --custom-remote '{{ tap.name }}' '{{ tap.remote }}'
    - runas: {{ brew.lookup.user }}
    # there is no onlyif_any to mean "only if any is true"
    # onlyif is evaluated to mean "onlyif all are true"
    # onlyif_any workaround
    # only if tap is already tapped and taps are configured to be force-set or if it's an official tap
    - onlyif:
        - |
            (sudo -u '{{ brew.lookup.user }}' {{ brew_bin }} tap | \
               grep '{{ tap.name }}' && {{ brew.get("taps_forced", false) | to_bool }}) || \
               {{ tap.name in brew.lookup.official_taps }}
    # unless it's already set to the custom target
    - unless:
        - |
            cd '{{ tap_dir }}' \
            && git remote get-url origin | grep '{{ tap.remote }}'
    - require:
        - Homebrew setup is completed
        - Homebrew env vars are set during this salt run

Homebrew tap '{{ tap.name }}' autoupdate status is managed:
  cmd.run:
    - name: git config --replace-all --local --bool homebrew.forceautoupdate {{ tap.autoupdate }}
    - cwd: {{ tap_dir }}
    - runas: {{ brew.lookup.user }}
    - unless:
        - |
            cd '{{ tap_dir }}' && \
            test "$(git config --get --local homebrew.forceautoupdate)" = "{{ tap.autoupdate | lower  }}"
    - require_any:
        - Homebrew tap '{{ tap.name }}' is available
        - Homebrew tap '{{ tap.name }}' is force-set to custom remote
  {%- endif %}
{%- endfor %}

{%- for tap in brew | traverse("taps:absent", []) %}

Homebrew tap '{{ tap }}' is unavailable:
  cmd.run:
    - name: {{ brew_bin }} untap '{{ tap }}'
    - onlyif:
        - sudo -u '{{ brew.lookup.user }}' {{ brew_bin }} tap | grep '{{ tap }}'
    - runas:
      - {{ brew.lookup.user }}
    - require:
        - Homebrew setup is completed
        - Homebrew env vars are set during this salt run
{%- endfor %}
