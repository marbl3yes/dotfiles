# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	zsh-autosuggestions
	zsh-completions
	zsh-syntax-highlighting
	git
	fzf
  fzf-tab
	node
	npm
	yarn
	docker
	mvn
	fnm
	sdk
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Add VSCode terminal configuration
# [[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

export ZDOTDIR=$HOME/.config/zsh

# Colors
autoload -Uz colors && colors

# Useful functions
source "$ZDOTDIR/zsh-functions"

# Normal files to source
zsh_add_file "zsh-exports"
zsh_add_file "zsh-aliases"

# Add starship prompt
eval "$(starship init zsh)"

# Enable zoxide, override `cd`
eval "$(zoxide init zsh --cmd cd)"

# FZF
case "$(uname -s)" in

Darwin)
	[ -f /opt/homebrew/bin/fzf/completion.zsh ] && source /opt/homebrew/bin/fzf/completion.zsh
	[ -f /opt/homebrew/bin/fzf/key-bindings.zsh ] && source /opt/homebrew/bin/fzf/key-bindings.zsh
  export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
	;;

Linux)
	[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
	[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
	;;

CYGWIN* | MINGW32* | MSYS* | MINGW*)
	# echo 'MS Windows'
	;;

*)
	# echo 'Other OS'
	;;
esac

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f $ZDOTDIR/completion/_fnm ] && fpath+="$ZDOTDIR/completion/"
# export FZF_DEFAULT_COMMAND='rg --hidden -l ""'
compinit

# FZF tab
FZF_TAB_PLUGIN=$HOME/.oh-my-zsh/custom/plugins/fzf-tab/fzf-tab.plugin.zsh
if test -f "$FZF_TAB_PLUGIN"; then
  source $FZF_TAB_PLUGIN
else
  echo "fzf-tab is not installed, install it from https://github.com/Aloxaf/fzf-tab and set FZF_TAB_PLUGIN"
fi

# Enable zsh history substring search
source $HOME/.oh-my-zsh/custom/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

_fzf_compgen_path() {
  fd --hidden  --exclude .git "$1" .
}

_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git "$1" .
}

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in  
    cd) fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}" "@" ;;
    ssh) fzf --preview 'dig {}' "$@" ;;
    cat|bat) fzf --preview 'bat -n --color=always {}' "$@" ;;
    vi) fzf --preview 'vi {}' "$@" ;;
    *) fzf --preview '$HOME/.config/zsh/fzf-preview.sh {}' "$@" ;;
  esac
}

# Enable history navigation using the up and down arrows
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Enable using fzf preview with eza when using tab completion `cd`
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:*' fzf-preview '$HOME/.config/zsh/fzf-preview.sh $realpath'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --color=always --icons=always --git $realpath | head -200'
zstyle ':fzf-tab:*' switch-group '<' '>'

# Configure zsh history
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=2000
export SAVEHIST=$HISTSIZE
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
setopt hist_ignore_space

# Tool exports
export BAT_THEME="Monokai Extended Bright"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}'"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
