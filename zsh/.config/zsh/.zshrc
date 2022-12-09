
# fnm
export PATH=/home/sergio-pereira/.fnm:$PATH
eval "`fnm env`"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/sergio-pereira/.sdkman"
[[ -s "/home/sergio-pereira/.sdkman/bin/sdkman-init.sh" ]] && source "/home/sergio-pereira/.sdkman/bin/sdkman-init.sh"

# fnm
export PATH="/home/sergio-pereira/.local/share/fnm:$PATH"
eval "`fnm env`"
