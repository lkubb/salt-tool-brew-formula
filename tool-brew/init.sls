{%- from 'tool-brew/map.jinja' import brew -%}

include:
  - .package
{%- if brew.globalpath is defined %}
  - .globalpath
{%- endif %}
  - .env
{%- if brew.get('taps') or brew.get('untaps') %}
  - .taps
{%- endif %}
{%- if brew.get('packages') %}
  - .packages
{%- endif %}
{%- if brew.get('gnu_link') %}
  - .gnu
{%- endif %}
