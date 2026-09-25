# dotfiles

Managed with [chezmoi](https://www.chezmoi.io).

## New machine

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply gh:marbl3yes/dotfiles
make install
```

Answer the prompt with `desktop` or `server`. Configs select themselves per OS and role:

- shared: zsh, nvim, starship, lazygit, Herdr config, vim, ideavim, auto-scripts
- desktops: Ghostty (Homebrew cask on macOS; Ubuntu package when available)
- macOS only: macOS `defaults` tweaks
- Linux desktop only: i3, i3status, picom, dunst
- servers: shared tools only (no Ghostty)

The install script asks before installing Herdr when it is missing. If the script
runs without a terminal, it prints the [manual install instructions](https://herdr.dev/docs/install/).
The Herdr config includes shortcuts for optional plugins; install those separately
in Herdr if you want the shortcuts to work.

## Existing machine

```sh
make link      # stage 1: apply config files
make install   # stage 2: install packages / apply defaults
make all       # both
```

Machine-local PATH exports live in `dot_config/zsh/zsh-local.tmpl`, guarded by hostname, so they survive reformats.
