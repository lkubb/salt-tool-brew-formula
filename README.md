# Homebrew Formula
Sets up and configures Homebrew on MacOS.

## Usage
Applying `tool-brew` will make sure `brew` is configured as specified.

## Configuration
### Pillar
#### General `tool` architecture
Since installing user environments is not the primary use case for saltstack, the architecture is currently a bit awkward. All `tool` formulas assume running as root. There are three scopes of configuration:
1. per-user `tool`-specific
  > e.g. generally force usage of XDG dirs in `tool` formulas for this user
2. per-user formula-specific
  > e.g. setup this tool with the following configuration values for this user
3. global formula-specific (All formulas will accept `defaults` for `users:username:formula` default values in this scope as well.)
  > e.g. setup system-wide configuration files like this

**3** goes into `tool:formula` (e.g. `tool:git`). Both user scopes (**1**+**2**) are mixed per user in `users`. `users` can be defined in `tool:users` and/or `tool:formula:users`, the latter taking precedence. (**1**) is namespaced directly under `username`, (**2**) is namespaced under `username: {formula: {}}`.

```yaml
tool:
######### user-scope 1+2 #########
  users:                         #
    username:                    #
      xdg: true                  #
      dotconfig: true            #
      formula:                   #
        config: value            #
####### user-scope 1+2 end #######
  formula:
    formulaspecificstuff:
      conf: val
    defaults:
      yetanotherconfig: somevalue
######### user-scope 1+2 #########
    users:                       #
      username:                  #
        xdg: false               #
        formula:                 #
          otherconfig: otherval  #
####### user-scope 1+2 end #######
```

#### User-specific
The following shows an example of `tool-brew` pillar configuration. Namespace it to `tool:users` and/or `tool:brew:users`.
```yaml
user:
  persistenv: '.config/zsh/zshenv'  # persist env vars specified in salt to this file (will be appended to file relative to $HOME)
  rchook: '.config/zsh/zshrc'       # add runcom hooks to this file (will be appended to file relative to $HOME)
```

#### Formula-specific
```yaml
tool:
  brew:
    user: username # Specify brew user. Defaults to console user.
    prefix: /opt/homebrew # specify custom brew prefix (not recommended)
    repodir: /brew        # specify custom dir relative to prefix (not recommended)
    # It's possible to provide a local mirror for brew repositories.
    # Mind that you will need to set the matching env vars afterwards:
    #   HOMEBREW_{BREW,CORE}_GIT_REMOTE
    # Local mirrors for casks can be set in taps.
    mirror_brew: https://mygit.example.com/my/brew
    mirror_core: https://mygit.example.com/my/homebrew-core
    # Specify configuration env vars to be used during salt run.
    config:
      - HOMEBREW_NO_ANALYTICS
      - HOMEBREW_NO_INSECURE_REDIRECT
      - HOMEBREW_CASK_OPTS:
          - --require-sha
          - --no-quarantine
    # homebrew-cask* mirrors and custom taps go here:
    taps:
        # If you specify the name of an official tap, the remote will be matched.
        # If you specify the name of an existing non-official tap and
        #   taps_forced is set to true, the remote will be matched.
      - homebrew/cask: https://mygit.example.com/my/homebrew-cask
      - homebrew/cask-versions: https://mygit.example.com/my/homebrew-cask-versions
      - homebrew/cask-drivers: https://mygit.example.com/my/homebrew-cask-drivers
      - homebrew/cask-fonts: https://mygit.example.com/my/homebrew-cask-fonts
        # brew tap short syntax works as well (mapped to github.com/<first>/homebrew-<second>)
      - blacktop/tap
      - my/customtap: https://mygit.example.com/my/custom-tap
    taps_autoupdate:
      # By default, taps not hosted on Github are not updated automatically
      # (for performance reasons). Force automatic updates for taps managed
      # with this formula, either by default or only for specific ones.
      # This formula forces autoupdate for mirrors of offical taps automatically.
      default: false
      my/customtap: true
    # Force override of existing remotes with specified ones (not necessary for mirrors of official taps).
    taps_forced: false
    untaps:
      - unwanted/tap
    # You can force linking unprefixed GNU versions of tools to /usr/local/gnubin
    # You will still need to add it to your path
    gnu_link: false
    # list of packages to install, mostly for bootstrap convenience
    packages:
      - git
      - wget
      - gpg
```
