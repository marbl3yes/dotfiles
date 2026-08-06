REPO ?= gh:marbl3yes/dotfiles

.PHONY: setup link install all

# Fresh machine: install chezmoi, clone repo, first apply (asks for role)
setup:
	@command -v chezmoi >/dev/null 2>&1 || sh -c "$$(curl -fsLS get.chezmoi.io)" -- init --apply $(REPO)

# Stage 1: link config files only (no run_once scripts)
link:
	chezmoi apply --exclude scripts

# Stage 2: run install/defaults scripts only
install:
	chezmoi apply --include scripts

all: link install
