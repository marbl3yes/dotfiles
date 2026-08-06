# Dotfiles -> chezmoi Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the Stow-based `dotfiles` repo into a chezmoi source layout so the same configs provision reproducibly on macOS (desktop) and the Ubuntu server, staged via a Makefile.

**Architecture:** Restructure the existing repo in place to chezmoi's `dot_`/`dot_config/` source conventions, select per-OS/per-role files via a templated `.chezmoiignore` (`role` prompted at init), replace `fresh_install.sh` with `run_once_` scripts that branch on `.chezmoi.os`, and keep machine-local PATH exports in a committed hostname-guarded template so they survive reformats. The repo moves from `~/dotfiles` to `~/.local/share/chezmoi` (chezmoi's default source dir).

**Tech Stack:** chezmoi, GNU Stow (being removed), zsh, bash, GNU Make, Go templates.

**Repo state at start:** branch `main`, remote `git@github.com:marbl3yes/dotfiles.git`. Machine facts gathered: Mac hostname `Sergios-Laptop.local`; `~/.zshenv` does NOT exist so `~/.zshrc` is the live config and `~/.config/zsh/.zshrc` is a dead duplicate; live stow symlinks: `~/.zshrc`, `~/.vimrc`, `~/.ideavimrc`, `~/.vim`, `~/.config/{zsh,nvim,lazygit,wezterm,auto_node_version_switch.sh,starship.toml,vscode-java.prefs}`.

Note: this plan deliberately runs in the repo checkout itself (not a worktree) because the repo *is* the thing being transformed.

---

## File structure (final)

All paths are under `~/.local/share/chezmoi/` (the repo after Task 1).

```
.chezmoi.toml.tmpl            # prompts role (desktop/server) at `chezmoi init`
.chezmoiignore                # per-OS / per-role exclusions (template)
.chezmoiversion               # minimum chezmoi version
.gitignore                    # updated for new layout
Makefile                      # setup / link / install / all
README.md                     # new setup instructions
dot_zshrc                     # ~/.zshrc (cleaned; sources zsh-local)
dot_vimrc                     # ~/.vimrc
dot_vim/autoload/plug.vim     # ~/.vim/autoload/plug.vim
dot_ideavimrc                 # ~/.ideavimrc
dot_config/
+-- zsh/
|   +-- zsh-aliases
|   +-- zsh-exports
|   +-- zsh-functions
|   +-- zsh-prompt
|   +-- zsh-vim-mode
|   +-- zsh-local.tmpl        # hostname-guarded machine-local exports
|   +-- fzf-preview.sh
|   +-- completion/_fnm
|   +-- .zshenv
|   +-- .zprofile
+-- nvim/**                   # ported as-is (README/LICENSE ignored)
+-- starship.toml
+-- lazygit/config.yml
+-- wezterm/wezterm.lua       # macOS + Linux desktop (ignored on server)
+-- auto_node_version_switch.sh
+-- vscode-java.prefs
+-- i3/**                     # linux only
+-- dunst/dunstrc             # linux only
run_once_before_install-packages.sh.tmpl
run_once_after_macos-defaults.sh.tmpl
docs/superpowers/**           # spec + this plan (ignored by chezmoi)
```

Deleted: `fresh_install.sh`, `.stow-local-ignore`, all old package dirs, and the dead `~/.config/zsh/.zshrc` duplicate.

---

### Task 1: Install chezmoi and move the repo into place

**Files:**
- Machine state: `~/dotfiles` -> `~/.local/share/chezmoi`

- [ ] **Step 1: Install chezmoi on the Mac**

```bash
brew install chezmoi
```

Run: `chezmoi --version`
Expected: prints a `chezmoi version vX.Y.Z` line.

- [ ] **Step 2: Move the repo to chezmoi's source dir**

```bash
mkdir -p ~/.local/share
mv ~/dotfiles ~/.local/share/chezmoi
```

Run: `cd ~/.local/share/chezmoi && git remote -v`
Expected: `origin  git@github.com:marbl3yes/dotfiles.git` still present (repo history intact).

- [ ] **Step 3: Sanity-check the working tree**

Run: `cd ~/.local/share/chezmoi && git status --short`
Expected: clean (nothing staged/modified).

---

### Task 2: Restructure repo into chezmoi source layout

**Files:**
- Renames across the whole repo (via `git mv`), deletions of `fresh_install.sh`, `.stow-local-ignore`

- [ ] **Step 1: Move every package into the chezmoi layout**

```bash
cd ~/.local/share/chezmoi

mkdir -p dot_config
git mv auto-scripts/.config/auto_node_version_switch.sh dot_config/auto_node_version_switch.sh
git mv dunst/.config/dunst dot_config/dunst
git mv i3/.config/i3 dot_config/i3
git mv lazygit/.config/lazygit dot_config/lazygit
git mv nvim/.config/nvim dot_config/nvim
git mv starship/.config/starship.toml dot_config/starship.toml
git mv vscode/.config/vscode-java.prefs dot_config/vscode-java.prefs
git mv wezterm/.config/wezterm dot_config/wezterm
git mv vim/.vim dot_vim
git mv vim/.vimrc dot_vimrc
git rm vim/.gitignore
git mv ideavim/.ideavimrc dot_ideavimrc
git mv zsh/.config/zsh dot_config/zsh
git mv zsh/.zshrc dot_zshrc
git rm fresh_install.sh .stow-local-ignore
```

- [ ] **Step 2: Remove now-empty leftover directories**

```bash
cd ~/.local/share/chezmoi
rmdir -p auto-scripts/.config dunst/.config lazygit/.config nvim/.config starship/.config vscode/.config wezterm/.config zsh/.config vim 2>/dev/null || true
```

- [ ] **Step 3: Verify the new structure**

Run:
```bash
cd ~/.local/share/chezmoi
git ls-files
```
Expected: only `dot_*` paths, `.gitignore`, `README.md`, and no `fresh_install.sh`/`.stow-local-ignore`. Confirm `dot_config/nvim/` contents moved with `ls dot_config/nvim`.

- [ ] **Step 4: Commit**

```bash
cd ~/.local/share/chezmoi
git add -A
git commit -m "Restructure repo into chezmoi source layout"
```

---

### Task 3: Clean up the zsh config

**Files:**
- Modify: `dot_zshrc`
- Create: `dot_config/zsh/zsh-local.tmpl`
- Delete: `dot_config/zsh/.zshrc` (dead duplicate)

- [ ] **Step 1: Remove the machine-specific PATH exports from `dot_zshrc`**

Edit `dot_zshrc` and delete these three blocks (keep everything else unchanged):

1. The "Antigravity" block:
```
# Added by Antigravity
export PATH="/Users/sergio.pereira/.antigravity/antigravity/bin:$PATH"

# Added by Antigravity IDE
export PATH="/Users/sergio.pereira/.antigravity-ide/antigravity-ide/bin:$PATH"

# Added by Antigravity CLI installer
export PATH="/Users/sergio.pereira/.local/bin:$PATH"
```
2. The "LM Studio" block:
```
# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/sergio.pereira/.lmstudio/bin"
# End of LM Studio CLI section
```
3. The "Pi" pinned fnm line (last line):
```
# Pi
export PATH="/Users/sergio.pereira/.local/share/fnm/node-versions/v24.15.0/installation/bin:$PATH"
```

The commented `# API keys variables` block is kept as documentation.

- [ ] **Step 2: Source the machine-local file**

Edit `dot_zshrc` — directly after this line:
```
zsh_add_file "zsh-aliases"
```
insert:
```
zsh_add_file "zsh-local"
```

- [ ] **Step 3: Delete the dead duplicate `.zshrc`**

```bash
cd ~/.local/share/chezmoi
git rm dot_config/zsh/.zshrc
```
Rationale: `~/.zshenv` does not exist on the Mac, so `ZDOTDIR` defaults to `$HOME`, `~/.zshrc` is live, and `~/.config/zsh/.zshrc` is never read.

- [ ] **Step 4: Create `dot_config/zsh/zsh-local.tmpl`**

```text
{{- if eq .chezmoi.hostname "Sergios-Laptop.local" }}
# macOS: Antigravity, LM Studio, pinned fnm node version
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.antigravity-ide/antigravity-ide/bin:$PATH"
export PATH="$PATH:$HOME/.lmstudio/bin"
export PATH="$HOME/.local/share/fnm/node-versions/v24.15.0/installation/bin:$PATH"
{{- end }}

{{- if eq .chezmoi.hostname "<ubuntu-server-hostname>" }}
# Ubuntu server: machine-specific exports go here
{{- end }}
```
`<ubuntu-server-hostname>` is filled in during Task 10 on the server (run `chezmoi execute-template '{{ .chezmoi.hostname }}'` there).

- [ ] **Step 5: Verify syntax and template rendering**

Run:
```bash
cd ~/.local/share/chezmoi
zsh -n dot_zshrc && echo "zsh OK"
chezmoi execute-template < dot_config/zsh/zsh-local.tmpl
```
Expected: `zsh OK`; template output shows only the `Sergios-Laptop.local` block (hostname is auto-detected, no config needed).

- [ ] **Step 6: Commit**

```bash
cd ~/.local/share/chezmoi
git add -A
git commit -m "Clean up zsh config and add hostname-guarded zsh-local template"
```

---

### Task 4: Create chezmoi special files and initialize config

**Files:**
- Create: `.chezmoi.toml.tmpl`, `.chezmoiignore`, `.chezmoiversion`
- Machine state: `~/.config/chezmoi/chezmoi.toml` (written by `chezmoi init`)

- [ ] **Step 1: Create `.chezmoi.toml.tmpl`**

```toml
{{- $role := promptStringOnce . "role" "Machine role (desktop/server): " }}
[data]
    role = {{ $role | quote }}
```

- [ ] **Step 2: Create `.chezmoiignore`**

```text
README.md
Makefile
docs/**

# LazyVim ships its own README/LICENSE — don't copy them to ~/.config/nvim
dot_config/nvim/README.md
dot_config/nvim/LICENSE

# i3/dunst are Linux-desktop-only
{{ if ne .chezmoi.os "linux" }}
dot_config/i3/**
dot_config/dunst/**
{{ end }}

# wezterm is not installed on servers
{{ if eq .role "server" }}
dot_config/wezterm/**
{{ end }}
```

- [ ] **Step 3: Create `.chezmoiversion`**

```text
2.40.0
```

- [ ] **Step 4: Initialize chezmoi (prompts for role)**

```bash
cd ~/.local/share/chezmoi
chezmoi init
```
Answer the prompt with `desktop`.

- [ ] **Step 5: Verify role data is in the config**

Run:
```bash
chezmoi data | grep role
```
Expected: `"role": "desktop"` (or the TOML/JSON form).

- [ ] **Step 6: Commit**

```bash
cd ~/.local/share/chezmoi
git add .chezmoi.toml.tmpl .chezmoiignore .chezmoiversion
git commit -m "Add chezmoi config, ignore, and version files"
```

---

### Task 5: Write the bootstrap run scripts

**Files:**
- Create: `run_once_before_install-packages.sh.tmpl`, `run_once_after_macos-defaults.sh.tmpl`

- [ ] **Step 1: Create `run_once_before_install-packages.sh.tmpl`**

```sh
#!/bin/bash
set -euo pipefail

case "{{ .chezmoi.os }}" in
  darwin)
    brew install fzf fd bat eza zoxide starship lazygit neovim fnm
    brew install zsh-autosuggestions zsh-completions zsh-syntax-highlighting
    brew install --cask wezterm
    ;;
  linux)
    sudo apt update
    sudo apt install -y zsh fzf fd-find bat eza zoxide starship lazygit
    sudo chsh -s "$(command -v zsh)" "$USER"

    # Ubuntu names the binaries fd/fdfind and bat/batcat — provide the expected names
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"

    # fnm is not packaged in Ubuntu — install the official script
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell

    # Neovim: apt's version is too old for LazyVim, install the official release
    case "$(uname -m)" in
      x86_64)  nvim_url="https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz" ;;
      aarch64) nvim_url="https://github.com/neovim/neovim/releases/download/stable/nvim-linux-aarch64.tar.gz" ;;
    esac
    curl -fsSL "$nvim_url" -o /tmp/nvim.tar.gz
    nvim_dir="$(tar tzf /tmp/nvim.tar.gz | sed -n '1s#/.*##p')"
    sudo tar xf /tmp/nvim.tar.gz -C /opt
    sudo ln -sf "/opt/$nvim_dir/bin/nvim" /usr/local/bin/nvim

    # Oh-my-zsh + the plugins referenced by .zshrc
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
      git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
      git clone https://github.com/zsh-users/zsh-completions "$HOME/.oh-my-zsh/custom/plugins/zsh-completions"
      git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
      git clone https://github.com/Aloxaf/fzf-tab "$HOME/.oh-my-zsh/custom/plugins/fzf-tab"
      git clone https://github.com/zsh-users/zsh-history-substring-search "$HOME/.oh-my-zsh/custom/plugins/zsh-history-substring-search"
    fi
{{ if ne .role "server" }}
    # GUI terminal — linux desktop only, skipped on servers
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
    sudo apt update
    sudo apt install -y wezterm
{{ end }}
    ;;
esac
```

- [ ] **Step 2: Verify the darwin branch renders and is syntactically valid**

Run:
```bash
cd ~/.local/share/chezmoi
chezmoi execute-template < run_once_before_install-packages.sh.tmpl | bash -n && echo "bash OK"
```
Expected: `bash OK`; rendered output shows the `darwin` branch (role is `desktop` in config, so the server-only wezterm block is absent).

- [ ] **Step 3: Create `run_once_after_macos-defaults.sh.tmpl`**

```sh
#!/bin/bash
set -euo pipefail
{{ if eq .chezmoi.os "darwin" }}
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
{{ end }}
```

- [ ] **Step 4: Verify it renders and is valid**

Run:
```bash
cd ~/.local/share/chezmoi
chezmoi execute-template < run_once_after_macos-defaults.sh.tmpl | bash -n && echo "bash OK"
```
Expected: `bash OK`.

- [ ] **Step 5: Commit**

```bash
cd ~/.local/share/chezmoi
git add run_once_before_install-packages.sh.tmpl run_once_after_macos-defaults.sh.tmpl
git commit -m "Add per-OS chezmoi install and defaults scripts"
```

---

### Task 6: Write the staged Makefile

**Files:**
- Create: `Makefile`

- [ ] **Step 1: Create `Makefile`**

```make
REPO ?= gh:marbl3yes/dotfiles

.PHONY: setup link install all

# Fresh machine: install chezmoi, clone repo, first apply (asks for role)
setup:
	@command -v chezmoi >/dev/null 2>&1 || sh -c "$$(curl -fsLS get.chezmoi.io)" -- init --apply $(REPO)

# Stage 1: link config files only
link:
	chezmoi apply --include files

# Stage 2: run install/defaults scripts only
install:
	chezmoi apply --include scripts

all: link install
```

- [ ] **Step 2: Verify targets resolve**

Run:
```bash
cd ~/.local/share/chezmoi
make -n link
```
Expected: prints `chezmoi apply --include files` (does not execute it).

- [ ] **Step 3: Commit**

```bash
cd ~/.local/share/chezmoi
git add Makefile
git commit -m "Add staged Makefile for provisioning"
```

---

### Task 7: Update README and .gitignore

**Files:**
- Modify: `README.md`, `.gitignore`

- [ ] **Step 1: Replace `.gitignore`**

Write this to `.gitignore`:
```text
.DS_Store

# Zsh
.zsh_history
.zcompdump-*

# Vim
Session.vim

# Neovim
dot_config/nvim/plugin/packer_compiled.lua
```

- [ ] **Step 2: Replace `README.md`**

The new README contains the following sections (in this order):

1. Title `# dotfiles` and one line: `Managed with [chezmoi](https://www.chezmoi.io).`
2. `## New machine` with a code block containing the bootstrap command:
   `sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply gh:marbl3yes/dotfiles`
   followed by `make install`.
3. A note: "Answer the prompt with `desktop` or `server`. Configs select themselves per OS and role:"
   followed by a bullet list:
   - shared: zsh, nvim, starship, lazygit, vim, ideavim, auto-scripts
   - macOS only: wezterm (also on Linux desktops), macOS `defaults` tweaks
   - Linux desktop only: i3, dunst
   - servers: shared tools only (no wezterm)
4. `## Existing machine` with a code block:
   `make link` (stage 1: apply config files), `make install` (stage 2: install packages / apply defaults), `make all` (both)
5. One line: "Machine-local PATH exports live in `dot_config/zsh/zsh-local.tmpl`, guarded by hostname, so they survive reformats."

- [ ] **Step 3: Verify no stray files are tracked**

Run: `cd ~/.local/share/chezmoi && git status --short`
Expected: only `README.md` and `.gitignore` modified.

- [ ] **Step 4: Commit**

```bash
cd ~/.local/share/chezmoi
git add README.md .gitignore
git commit -m "Update README and gitignore for chezmoi layout"
```

---

### Task 8: Apply configs on the Mac and verify

**Files:**
- Machine state: `$HOME` configs (replaces the old stow symlinks)

- [ ] **Step 1: Remove the now-dangling stow symlinks**

```bash
for target in \
  "$HOME/.zshrc" "$HOME/.vimrc" "$HOME/.ideavimrc" "$HOME/.vim" \
  "$HOME/.config/zsh" "$HOME/.config/nvim" "$HOME/.config/lazygit" \
  "$HOME/.config/wezterm" "$HOME/.config/auto_node_version_switch.sh" \
  "$HOME/.config/starship.toml" "$HOME/.config/vscode-java.prefs"; do
  [ -L "$target" ] && rm "$target"
done
```
This only removes symlinks; real files are left alone.

- [ ] **Step 2: Apply configs (files only — no scripts yet)**

```bash
cd ~/.local/share/chezmoi
chezmoi apply --include files
```

- [ ] **Step 3: Verify no drift and correct exclusions**

Run:
```bash
cd ~/.local/share/chezmoi
chezmoi diff        # expect: no output (clean)
chezmoi ignored     # expect: README.md, Makefile, docs/**, i3/**, dunst/** — NOT wezterm
chezmoi managed     # expect: the full list of managed files
```

- [ ] **Step 4: Sanity-check the shell**

Run: `zsh -n "$HOME/.zshrc" && echo "zshrc OK"`
Expected: `zshrc OK`. Open a new terminal tab and confirm the prompt (starship) and aliases load.

- [ ] **Step 5: Confirm wezterm config landed on the Mac**

Run: `ls -la "$HOME/.config/wezterm/wezterm.lua"`
Expected: a real (non-symlink) file managed by chezmoi.

---

### Task 9: Commit final state and push

- [ ] **Step 1: Commit any remaining changes**

```bash
cd ~/.local/share/chezmoi
git add -A
git status --short   # should be clean or only intended changes
git commit -m "Finalize chezmoi migration" || echo "nothing to commit"
```

- [ ] **Step 2: Push**

```bash
cd ~/.local/share/chezmoi
git push origin main
```
Expected: remote `marbl3yes/dotfiles` updated with the new layout.

---

### Task 10: Provision the Ubuntu server (run on the server)

This task is executed **on the server**, not on the Mac.

- [ ] **Step 1: Bootstrap chezmoi and apply**

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply gh:marbl3yes/dotfiles
```
Answer the prompt with `server`.

- [ ] **Step 2: Get the server hostname**

```sh
chezmoi execute-template '{{ .chezmoi.hostname }}'
```
Expected: the server's hostname, e.g. `ubuntu-server`.

- [ ] **Step 3: Add the server's machine-local block**

Edit `dot_config/zsh/zsh-local.tmpl` in `~/.local/share/chezmoi/` and replace the placeholder:
```text
{{- if eq .chezmoi.hostname "<ubuntu-server-hostname>" }}
# Ubuntu server: machine-specific exports go here
{{- end }}
```
with a block using the hostname from Step 2 and any server-specific exports. Commit and push:
```sh
cd ~/.local/share/chezmoi
git add dot_config/zsh/zsh-local.tmpl
git commit -m "Add server machine-local exports"
git push origin main
```

- [ ] **Step 4: Run the install stage**

```sh
cd ~/.local/share/chezmoi
make install
```
Expected: apt packages installed for shared tools; wezterm is **not** installed (role=server).

- [ ] **Step 5: Verify the result**

```sh
chezmoi diff        # expect: no output (clean)
chezmoi ignored     # expect: wezterm/** ignored (role=server); i3/dunst present but not applied
test -d ~/.config/wezterm && echo "FAIL: wezterm present" || echo "OK: no wezterm"
```
Open a zsh shell and confirm the starship prompt loads.

---

## Acceptance criteria (from spec)

- [ ] `chezmoi apply` is idempotent on the Mac; `chezmoi diff` shows no drift after the initial apply.
- [ ] On the Mac, wezterm is installed via brew and its config is applied.
- [ ] A fresh Ubuntu server provisions shared configs with the two-command flow, with no i3/dunst/wezterm applied, and machine-local exports present for its hostname.
- [ ] `fresh_install.sh`, Stow files (`.stow-local-ignore`), and Stow symlinks are gone.
- [ ] Secrets never appear in the repo; only non-secret machine-local content is committed.
