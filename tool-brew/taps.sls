{%- from 'tool-brew/map.jinja' import brew -%}

{%- set official_taps = [
  'homebrew/cask',
  'homebrew/cask-versions',
  'homebrew/cask-drivers',
  'homebrew/cask-fonts',
  ] -%}

{%- set parsed_taps = [] %}

{%- for tap in brew.get('taps', []) -%}
  {%- set tap_name = tap if tap is string else tap.keys() | first -%}
  {%- set tap_remote = tap[tap_name] if tap is mapping else '' -%}
  {%- set autoupdate = False %}
  {%- if tap_remote -%}
    {%- set autoupdate =
          brew.get('taps_autoupdate', {}).get('default', False) | to_bool or
          (tap_name in brew.get('taps_autoupdate', {}).keys() and brew.taps_autoupdate[tap_name]) or
          tap_name in official_taps
    -%}
  {%- endif -%}
  {%- do parsed_taps.append({
    'name': tap_name,
    'remote': tap_remote,
    'autoupdate': autoupdate,
  }) -%}
{%- endfor %}

include:
  - .package
  - .env

{%- for tap in parsed_taps %}

Homebrew tap '{{ tap.name }}' is available:
  cmd.run:
    - name: {{ brew._prefix }}/bin/brew tap '{{ tap.name }}'{% if tap.remote %} '{{ tap.remote }}'{% endif %}
    - runas: {{ brew._user }}
    # there is no unless_any to mean "unless any is true".
    # unless is evaluated to mean "unless all are true"
    # unless_any workaround
    - unless:
        - |
            sudo -u '{{ brew._user }}' {{ brew._prefix }}/bin/brew tap | grep '{{ tap.name }}' \
            || '{{ tap.name in official_taps }}'
    - require:
        - Homebrew setup is completed
        - Homebrew env vars are set during this salt run

  {%- if tap.remote %}

Homebrew tap '{{ tap.name }}' is force-set to custom remote:
  cmd.run:
    - name: {{ brew._prefix }}/bin/brew tap {% if tap.autoupdate %}--force-auto-update {% endif %}--custom-remote '{{ tap.name }}' '{{ tap.remote }}'
    - runas: {{ brew._user }}
    # there is no onlyif_any to mean "only if any is true"
    # onlyif is evaluated to mean "onlyif all are true"
    # onlyif_any workaround
    # only if tap is already tapped and taps are configured to be force-set or if it's an official tap
    - onlyif:
        - |
            (sudo -u '{{ brew._user }}' {{ brew._prefix }}/bin/brew tap | \
               grep '{{ tap.name }}' && {{ brew.get('taps_forced', False) | to_bool }}) \
            || '{{ tap.name in official_taps }}'
    # unless it's already set to the custom target
    - unless:
        - |
            cd "{{ brew._prefix }}/Library/Taps/{{ tap.name.split('/')[0] }}/homebrew-{{ tap.name.split('/')[1] }}" \
            && git remote get-url origin | grep '{{ tap.remote }}'
    - require:
        - Homebrew setup is completed
        - Homebrew env vars are set during this salt run

Homebrew tap '{{ tap.name }}' autoupdate status is managed:
  cmd.run:
    - name: |
        cd "{{ brew._prefix }}/Library/Taps/{{ tap.name.split('/')[0] }}/homebrew-{{ tap.name.split('/')[1] }}" \
        && git config --replace-all --local --bool homebrew.forceautoupdate {{ tap.autoupdate }}
    - runas: {{ brew._user }}
    - unless:
        - |
            cd "{{ brew._prefix }}/Library/Taps/{{ tap.name.split('/')[0] }}/homebrew-{{ tap.name.split('/')[1] }}" && \
            test "$(git config --get --local homebrew.forceautoupdate)" = "{{ tap.autoupdate | lower  }}"
    - require_any:
        - Homebrew tap '{{ tap.name }}' is available
        - Homebrew tap '{{ tap.name }}' is force-set to custom remote
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
