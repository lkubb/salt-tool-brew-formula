# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as brew with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch %}

include:
  - {{ tplroot }}.command_line_tools
  - {{ tplroot }}.env_vars


{%- set brew_installed = not not "brew" | which %}
{%- set version = brew.init_version or "already_installed" %}

{%- if not brew.init_version and not brew_installed %}
{%-   set version = salt["cmd.run_stdout"](
      "curl -ILs -o /dev/null -w %{url_effective} '" ~ brew.lookup.pkg_src.latest ~
      "' | grep -o '[^/]*$' | sed 's/v//'",
      python_shell=true,
    )
%}
{%- endif %}

Homebrew macOS package is present:
  file.managed:
    - name: /tmp/brew.pkg
    - source: {{ brew.lookup.pkg_src.source.format(version=version) }}
{%-   if brew.lookup.pkg_src.source_hash %}
    - source_hash: {{ brew.lookup.pkg_src.source_hash.format(version=version) }}
{%-   else %}
    - skip_verify: true
{%-   endif %}
    - mode: '0600'
    - require:
      - sls: {{ tplroot }}.command_line_tools
      - sls: {{ tplroot }}.env_vars
    - unless:
      - '{{ brew_installed | lower }}'

Homebrew pkg user file is present:
  file.managed:
    - name: {{ brew.lookup.pkg_user_path }}
    - source: {{ files_switch(
                    ["homebrew_pkg_user.plist", "homebrew_pkg_user.plist.j2"],
                    lookup="Homebrew is installed",
                    config=brew,
                 )
              }}
    - context:
        brew: {{ brew | json }}
    - require:
      - sls: {{ tplroot }}.command_line_tools
      - sls: {{ tplroot }}.env_vars
    - unless:
      - '{{ brew_installed | lower }}'

Homebrew is installed:
  macpackage.installed:
    - name: /tmp/brew.pkg
    - target: /
    - force: true
    - unless:
      - '{{ brew_installed | lower }}'
    - require:
      - Homebrew macOS package is present
      - Homebrew pkg user file is present

Homebrew installation files are purged:
  file.absent:
    - names:
      - /tmp/brew.pkg
      - {{ brew.lookup.pkg_user_path }}
    - require:
      - Homebrew is installed

Homebrew setup is completed:
  test.nop:
    - name: Hooray, brew setup has finished successfully.
    - require:
        - Homebrew is installed
