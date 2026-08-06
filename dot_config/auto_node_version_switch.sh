# ZSH
autoload -U add-zsh-hook

load-nvmrc() {
  DEFAULT_NODE_VERSION="$(fnm ls | awk '/default/{print $2}')"
  CURRENT_NODE_VERSION="$(fnm current)"
  REQUIRED_NODE_VERSION=""

  if [[ -f .nvmrc && -r .nvmrc ]]; then
    REQUIRED_NODE_VERSION="$(cat .nvmrc)"

    if [[ $CURRENT_NODE_VERSION != $REQUIRED_NODE_VERSION ]]; then
      echo "Reverting to node from \"$CURRENT_NODE_VERSION\" to \"$REQUIRED_NODE_VERSION\""

      if fnm ls | grep -q $REQUIRED_NODE_VERSION; then
        fnm use $REQUIRED_NODE_VERSION
      else
        echo "Node version $REQUIRED_NODE_VERSION not found. Installing..."
        fnm install $REQUIRED_NODE_VERSION
        fnm use $REQUIRED_NODE_VERSION
      fi
    fi
  else
    if [[ $CURRENT_NODE_VERSION != $DEFAULT_NODE_VERSION ]]; then
      echo "Reverting to default node version: $DEFAULT_NODE_VERSION"
      fnm use $DEFAULT_NODE_VERSION
    fi
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc
