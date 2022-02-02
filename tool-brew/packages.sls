{%- from 'tool-brew/map.jinja' import brew -%}

include:
  - .package

{%- if brew.get('packages') %}

Default packages are installed with brew:
  pkg.installed:
    - pkgs: {{ brew.packages | json }}
    - require:
        - Homebrew setup is completed
{%- endif %}
