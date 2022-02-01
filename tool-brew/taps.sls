{%- from 'tool-brew/map.jinja' import brew -%}

include:
  - .package
  - .env

{%- set official_taps = [
  'homebrew/cask',
  'homebrew/cask-versions',
  'homebrew/cask-drivers',
  'homebrew/cask-fonts',
  ] %}

{%- for tap in brew.get('taps', []) %}
  {%- set tap_name = tap if tap is string else tap.keys() | first %}
  {%- set tap_remote = tap[tap_name] if tap is mapping else '' %}

Homebrew tap '{{ tap_name }}' is available:
  cmd.run:
    - name: {{ brew._prefix }}/bin/brew tap '{{ tap_name }}'{% if tap_remote %} '{{ tap_remote }}'{% endif %}
    - runas: {{ brew._user }}
    # there is no unless_any to mean "unless any is true".
    # unless is evaluated to mean "unless all are true"
    # unless_any workaround
    - unless:
        - |
            sudo -u '{{ brew._user }}' {{ brew._prefix }}/bin/brew tap | grep '{{ tap_name }}' \
            || '{{ tap_name in official_taps }}'
    - require:
        - Homebrew setup is completed
        - Homebrew env vars are set during this salt run

  {%- if tap_remote %}

Homebrew tap '{{ tap_name }}' is force-set to custom remote:
  cmd.run:
    - name: {{ brew._prefix }}/bin/brew tap --custom-remote '{{ tap_name }}' '{{ tap_remote }}'
    - runas: {{ brew._user }}
    # there is no onlyif_any to mean "only if any is true"
    # onlyif is evaluated to mean "onlyif all are true"
    # onlyif_any workaround
    - onlyif:
        - |
            (sudo -u '{{ brew._user }}' {{ brew._prefix }}/bin/brew tap | \
               grep '{{ tap_name }}' && {{ brew.get('taps_forced', False) | to_bool }}) \
            || '{{ tap_name in official_taps }}'
    - require:
        - Homebrew setup is completed
        - Homebrew env vars are set during this salt run

Homebrew tap '{{ tap_name }}' is updated automatically:
  cmd.run:
    - name: {{ brew._prefix }}/bin/brew tap --force-auto-update '{{ tap_name }}'
    - runas: {{ brew._user }}
    # onlyif_any workaround
    - onlyif:
        - ({{ brew.get('taps_autoupdate', {}).get('default', False) | to_bool }}) || \
          ({{ tap_name in brew.get('taps_autoupdate', {}).keys() and brew.taps_autoupdate[tap_name] }}) || \
          ({{ tap_name in official_taps }})
    - require_any:
        - Homebrew tap '{{ tap_name }}' is available
        - Homebrew tap '{{ tap_name }}' is force-set to custom remote
  {%- endif %}
{%- endfor %}

{%- for tap in brew.get('untaps', []) %}

Homebrew tap '{{ tap }}' is unavailable:
  cmd.run:
    - name: {{ brew._prefix }}/bin/brew untap '{{ tap }}'
    - onlyif:
        - sudo -u '{{ brew._user }}' {{ brew._prefix }}/bin/brew tap | grep '{{ tap }}'
    - runas:
      - {{ brew._user }}
    - require:
        - Homebrew setup is completed
        - Homebrew env vars are set during this salt run
{%- endfor %}
