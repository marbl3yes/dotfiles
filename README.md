# dotfiles

Managed with [chezmoi](https://www.chezmoi.io).

## New machine

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply gh:marbl3yes/dotfiles
make install
```

Answer the prompt with `desktop` or `server`. Configs select themselves per OS and role:

- shared: zsh, nvim, starship, lazygit, vim, ideavim, auto-scripts
- macOS only: wezterm (also on Linux desktops), macOS `defaults` tweaks
- Linux desktop only: i3, i3status, picom, dunst
- servers: shared tools only (no wezterm)

## Existing machine

```sh
make link      # stage 1: apply config files
make install   # stage 2: install packages / apply defaults
make all       # both
```

Machine-local PATH exports live in `dot_config/zsh/zsh-local.tmpl`, guarded by hostname, so they survive reformats.
