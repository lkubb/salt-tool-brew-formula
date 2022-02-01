{%- from 'tool-brew/map.jinja' import brew -%}

# inspired by https://github.com/elliotweiser/ansible-osx-command-line-tools
Command Line Tools are installed:
  cmd.run:
    - name: |
        set -o pipefail;
        touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
        PROD=$(softwareupdate -l | grep -B 1 -E 'Command Line Tools' | \
               awk -F'*' '/^\*/ {print $2}' | sed 's/^ Label: //' | grep -iE '[0-9|.]' | \
               sort | tail -n1);
        softwareupdate -i "$PROD" --verbose;
        rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
    - runas: {{ brew._user }}
    - unless:
        - test -d /Library/Developer/CommandLineTools
        - xcode-select -p &> /dev/null
        - pkgutil --pkg-info=com.apple.pkg.CLTools_Executables
