{%- from 'tool-brew/map.jinja' import brew -%}

{%- set custom_vars = [] -%}

{%- for var in brew.get('config', []) -%}
  {%- if var is string -%}
    {%- set parsed = (var, '1') -%}
  {%- else -%}
    {%- set parsed = (var.keys() | first, ' '.join(var.values() | first)) -%}
  {%- endif -%}
  {%- do custom_vars.append(parsed) -%}
{%- endfor -%}

Homebrew env vars are set during this salt run:
  environ.setenv:
    - value:
        HOMEBREW_PREFIX: '{{ brew._prefix }}'
        HOMEBREW_CELLAR: '{{ brew._target }}/Cellar'
        HOMEBREW_REPOSITORY: '{{ brew._target }}'
{%- for config in custom_vars %}
        {{ config[0] | upper }}: '{{ config[1] }}'
{%- endfor %}
