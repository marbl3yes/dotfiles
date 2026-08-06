# Design: Migrate dotfiles to chezmoi for OS-portable, reproducible setup

**Date:** 2026-08-05
**Status:** Approved

## Context

The repo currently stores dotfiles as GNU Stow packages. Configuring a new machine
is manual and fragile:

- `fresh_install.sh` is Debian/Ubuntu-only, requires root, hardcodes `username=1000`
  and x86_64 download URLs, and is not idempotent. It cannot run on macOS at all.
- Some configs are Linux-desktop-only (`i3/`, `dunst/`), most are cross-platform
  (zsh, nvim, starship, lazygit, wezterm, vim, ideavim).
- The Mac and Ubuntu machines should share configs "where possible", with small
  per-OS and per-environment deltas.

Goal: one coherent system covering setup, sync, and per-OS/per-environment
differences, so a fresh Mac or Ubuntu server can be provisioned reproducibly.

## Decisions

1. **Tool: chezmoi.** Adopt a dedicated dotfiles manager instead of hand-rolled
   Stow + scripts. Its built-in OS detection, per-host templating, and managed
   `run_` scripts directly address the stated goal.
2. **Repo:** Keep the existing GitHub repo named `dotfiles` (history preserved),
   but replace its contents with the chezmoi source layout. Stow is dropped.
3. **Machine-local paths:** Version them in the repo as hostname-guarded template
   blocks (not git-ignored local files), so they survive a reformat and are
   restored automatically by `chezmoi init --apply`. Secrets stay out of git
   (macOS Keychain pattern already present in `.zshrc`).
4. **Server:** GUI configs (wezterm) are skipped when `role == "server"`;
   i3/dunst are skipped on anything that is not a Linux desktop. Wezterm is
   installed and configured on macOS and on Linux desktops.

## Machine model

Every machine is classified on two axes:

- **OS** — auto-detected by chezmoi as `.chezmoi.os` (`darwin` / `linux`).
- **Role** — prompted once at `chezmoi init`, stored in the per-machine chezmoi
  config (`.chezmoi.toml.tmpl` writes it into `~/.config/chezmoi/chezmoi.toml`),
  available to templates as `.role`. Values: `desktop` | `server`.

`.chezmoiignore` (a template) performs the coarse-grained selection:

```text
{{ if ne .chezmoi.os "linux" }}
dot_config/i3/**
dot_config/dunst/**
{{ end }}

{{ if eq .role "server" }}
dot_config/wezterm/**
{{ end }}
```

Result:

| Machine | OS | Role | Configs applied |
|---|---|---|---|
| Mac | darwin | desktop | shared tools + wezterm (no i3/dunst) |
| Ubuntu server | linux | server | shared tools, no wezterm |
| (future) Linux desktop | linux | desktop | shared tools + wezterm + i3 + dunst |

## Repo layout

The repo root becomes the chezmoi source directory. chezmoi maps `dot_` to a
leading dot and `dot_config/` to `~/.config/`.

Target layout:

```text
dotfiles/                          (chezmoi source state)
├── .chezmoi.toml.tmpl             # prompts for role; writes ~/.config/chezmoi/chezmoi.toml
├── .chezmoiignore                 # per-OS / per-role exclusions
├── .chezmoiversion                # minimum chezmoi version
├── Makefile                       # staged provisioning targets
├── README.md                      # updated setup instructions
├── dot_zshrc                      # ~/.zshrc (see zsh cleanup below)
├── dot_vimrc                      # ~/.vimrc
├── dot_ideavimrc                  # ~/.ideavimrc
├── dot_config/
│   ├── zsh/
│   │   ├── zsh-aliases
│   │   ├── zsh-exports
│   │   ├── zsh-functions
│   │   ├── zsh-prompt
│   │   ├── zsh-vim-mode
│   │   ├── zsh-local.tmpl         # hostname-guarded machine-local exports
│   │   ├── fzf-preview.sh
│   │   ├── completion/_fnm
│   │   └── (one .zshrc / .zshenv / .zprofile — de-duplicated)
│   ├── nvim/**                    # ported as-is
│   ├── starship.toml
│   ├── lazygit/config.yml
│   ├── wezterm/wezterm.lua        # macOS + Linux desktop (ignored on server)
│   ├── auto_node_version_switch.sh
│   ├── i3/**                      # linux-desktop only
│   └── dunst/dunstrc              # linux-desktop only
├── run_once_before_install-packages.sh.tmpl   # brew vs apt, idempotent
└── run_once_after_macos-defaults.sh.tmpl      # darwin only: defaults write
```

## Source-to-target mapping

| Current (Stow) | chezmoi source | Target |
|---|---|---|
| `zsh/.zshrc` | `dot_zshrc` | `~/.zshrc` |
| `zsh/.config/zsh/zsh-aliases` | `dot_config/zsh/zsh-aliases` | `~/.config/zsh/zsh-aliases` |
| `zsh/.config/zsh/zsh-exports` | `dot_config/zsh/zsh-exports` | `~/.config/zsh/zsh-exports` |
| `zsh/.config/zsh/zsh-functions` | `dot_config/zsh/zsh-functions` | `~/.config/zsh/zsh-functions` |
| `zsh/.config/zsh/zsh-prompt` | `dot_config/zsh/zsh-prompt` | `~/.config/zsh/zsh-prompt` |
| `zsh/.config/zsh/zsh-vim-mode` | `dot_config/zsh/zsh-vim-mode` | `~/.config/zsh/zsh-vim-mode` |
| `zsh/.config/zsh/fzf-preview.sh` | `dot_config/zsh/fzf-preview.sh` | `~/.config/zsh/fzf-preview.sh` |
| `zsh/.config/zsh/completion/_fnm` | `dot_config/zsh/completion/_fnm` | `~/.config/zsh/completion/_fnm` |
| `nvim/.config/nvim/**` | `dot_config/nvim/**` | `~/.config/nvim/**` |
| `starship/.config/starship.toml` | `dot_config/starship.toml` | `~/.config/starship.toml` |
| `lazygit/.config/lazygit/config.yml` | `dot_config/lazygit/config.yml` | `~/.config/lazygit/config.yml` |
| `wezterm/.config/wezterm/wezterm.lua` | `dot_config/wezterm/wezterm.lua` | `~/.config/wezterm/wezterm.lua` |
| `auto-scripts/.config/auto_node_version_switch.sh` | `dot_config/auto_node_version_switch.sh` | `~/.config/auto_node_version_switch.sh` |
| `i3/.config/i3/**` | `dot_config/i3/**` | `~/.config/i3/**` |
| `dunst/.config/dunst/dunstrc` | `dot_config/dunst/dunstrc` | `~/.config/dunst/dunstrc` |
| `vim/.vimrc` | `dot_vimrc` | `~/.vimrc` |
| `ideavim/.ideavimrc` | `dot_ideavimrc` | `~/.ideavimrc` |
| `vscode/.config/vscode-java.prefs` | *verify consumer before porting* | ? |
| `fresh_install.sh` | **deleted** — replaced by run scripts | — |
| `.stow-local-ignore` | **deleted** | — |

## zsh cleanup

1. **De-duplicate `.zshrc`.** `zsh/.zshrc` and `zsh/.config/zsh/.zshrc` are
   byte-identical. Determine which one is actually live on the Mac (whether
   `ZDOTDIR` is set before zsh reads its rc files on that machine) and keep only
   that one in the repo.
2. **Remove hardcoded macOS-only paths** from the committed `.zshrc`:
   Antigravity, Antigravity IDE, LM Studio, and the pinned `fnm/node-versions/v24.15.0`
   PATH entry (all reference `/Users/sergio.pereira/...`). Their contents move to
   `zsh-local.tmpl` (below). The `.local/bin` export is retained as-is.
3. **Source machine-local file:** add `zsh_add_file "zsh-local"` alongside the
   existing `zsh_add_file "zsh-exports"` / `zsh_add_file "zsh-aliases"` calls.
   `zsh_add_file` already sources only when the file exists, so machines without
   a `zsh-local` are unaffected.
4. **Keep runtime `case "$(uname -s)"` branching** in `.zshrc`, `zsh-exports`,
   and `zsh-aliases` (fzf paths, fnm path). It already works across macOS and
   Linux; do not convert working runtime branching into templates.

## Machine-local content

`dot_config/zsh/zsh-local.tmpl` is committed and contains per-hostname blocks:

```text
{{- if eq .chezmoi.hostname "<mac-hostname>" }}
# macOS: Antigravity, LM Studio, pinned fnm node version
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.antigravity-ide/antigravity-ide/bin:$PATH"
export PATH="$PATH:$HOME/.lmstudio/bin"
export PATH="$HOME/.local/share/fnm/node-versions/v24.15.0/installation/bin:$PATH"
{{- end }}

{{- if eq .chezmoi.hostname "<ubuntu-server-hostname>" }}
# Ubuntu server: machine-specific exports
{{- end }}
```

- `.chezmoi.hostname` is auto-detected; no per-machine config required.
- A machine with no matching block renders an empty file, and chezmoi removes
  targets that render empty — so no stray empty `zsh-local` is created.
- This file is NOT secret content. Secrets (API keys) remain out of git; keep
  the existing macOS Keychain pattern (`security find-generic-password`) in
  `zsh-local.tmpl` per host if needed.

## Bootstrap scripts

`fresh_install.sh` is replaced by chezmoi scripts that branch on `.chezmoi.os`.
`run_once_` guarantees each runs at most once.

**`run_once_before_install-packages.sh.tmpl`** — package installation:

```sh
#!/bin/bash
set -euo pipefail

case "{{ .chezmoi.os }}" in
  darwin)
    brew install fzf fd bat eza zoxide starship lazygit neovim fnm wezterm zsh-autosuggestions zsh-completions zsh-syntax-highlighting
    ;;
  linux)
    sudo apt update
    sudo apt install -y zsh fzf fd-find bat eza zoxide starship nvim fnm
    {{- if ne .role "server" }}
    # GUI terminal — linux desktop only, skipped on servers
    sudo apt install -y wezterm
    {{- end }}
    ;;
esac
```

(Exact package lists finalized during implementation; brew/apt cask/package names
for nvim, lazygit, and wezterm-on-Linux may differ and are handled explicitly.)

**`run_once_after_macos-defaults.sh.tmpl`** — macOS-only tweaks:

```sh
#!/bin/bash
set -euo pipefail
{{ if eq .chezmoi.os "darwin" }}
defaults write com.apple.finder AppleShowAllFiles -bool true
# ... final macOS defaults during implementation
{{ end }}
```

Neither script requires root up front: Linux uses `sudo`, macOS uses `brew`.

## Staged provisioning (Makefile)

Honors the "staged bootstrap" preference. Targets at repo root:

```make
.PHONY: setup link install all

setup:   # install chezmoi, clone, first apply (includes role prompt)
link:    # chezmoi apply --include files        (configs only)
install: # chezmoi apply --include scripts      (packages + macOS defaults)
all: setup link install
```

`--include files` applies only file targets; `--include scripts` runs only the
install/defaults scripts.

## New machine provisioning

**Ubuntu server (fresh):**

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply gh:<you>/dotfiles   # answer "server" to role prompt
make install                                                            # apt packages for shared tools
```

No root session required; `sudo` prompts happen inside the install stage.

**Any machine reinstall:** the above is fully reproducible — configs, package
list, and machine-local hostname blocks all come from git.

## Mac migration steps

1. Restructure repo to the chezmoi layout above (in place, same GitHub repo).
2. `stow -D <pkg>` for each previously-stowed package to unlink the old symlinks.
3. Install chezmoi (`brew install chezmoi`), `chezmoi init` pointing at the repo,
   answer the role prompt (`desktop`).
4. `chezmoi apply` and reconcile any diffs (`chezmoi diff` first).
5. Verify the live `.zshrc` question and remove the dead duplicate.
6. Update `README.md` with the new setup flow.

## Open items to verify during implementation

- `vscode/.config/vscode-java.prefs` — identify which app reads it and its correct
  target path before porting; drop it if it is vestigial.
- Which of `~/.zshrc` / `~/.config/zsh/.zshrc` is live on the Mac (ZDOTDIR
  timing) — keep only the live one.
- Exact brew/apt package names for: nvim (neovim vs neovim-nightly), lazygit
  (brew formula vs GitHub release tarball), starship, fnm, eza.
- Confirm server hostname(s) and add their `zsh-local` blocks.
- Confirm `.chezmoiignore` paths match the final source layout (`chezmoi ignored`
  is the verification command).

## Acceptance criteria

- `chezmoi apply` is idempotent on the Mac; `chezmoi diff` shows no drift after
  the initial apply.
- On the Mac, wezterm is installed via brew and its config is applied.
- A fresh Ubuntu server provisions shared configs with the two-command flow, with
  no i3/dunst/wezterm applied, and machine-local exports present for its hostname.
- `fresh_install.sh`, Stow files (`.stow-local-ignore`), and Stow symlinks are gone.
- Secrets never appear in the repo; only non-secret machine-local content is
  committed.
