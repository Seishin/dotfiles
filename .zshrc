# =========================================================
# Powerlevel10k Instant Prompt (must stay at top)
# =========================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =========================================================
# Oh My Zsh
# =========================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  z
  fzf
)

source $ZSH/oh-my-zsh.sh

# =========================================================
# Theme & Auto-Switching
# =========================================================
# Detect macOS system theme
if defaults read -g AppleInterfaceStyle &>/dev/null; then
  # ---- DARK MODE ----
  [[ -f ~/.p10k-dark.zsh ]] && source ~/.p10k-dark.zsh
  
  # Lighter grey for dark backgrounds
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=248' 
  
  # Optional: fzf dark theme
  export FZF_DEFAULT_OPTS="--color=dark"
else
  # ---- LIGHT MODE ----
  [[ -f ~/.p10k-light.zsh ]] && source ~/.p10k-light.zsh
  
  # Darker grey for readability on white/light backgrounds
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240' 
  
  # Optional: fzf light theme
  export FZF_DEFAULT_OPTS="--color=light"
fi

# =========================================================
# Terminal / Homebrew
# =========================================================
export TERM=xterm-256color
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=false

# =========================================================
# Core SDKs
# =========================================================

# Android
export ANDROID_HOME="$HOME/Library/Android/sdk"

# Java (Zulu 17)
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"

# Bun
export BUN_INSTALL="$HOME/.bun"

# =========================================================
# PATH (single consolidated definition)
# Order matters: custom tools → language managers → system
# Uses the zsh `path` array (tied to $PATH) instead of a
# multi-line string — embedded newlines in a plain PATH
# string become part of each entry and silently break lookup.
# =========================================================
typeset -U path
path=(
  $BUN_INSTALL/bin
  $HOME/.antigravity/antigravity/bin
  $HOME/.rbenv/bin
  $ANDROID_HOME/emulator
  $ANDROID_HOME/platform-tools
  /opt/homebrew/opt/ruby/bin
  /usr/local/opt/ruby/bin
  /usr/local/opt/openjdk@17/bin
  /Library/Frameworks/Python.framework/Versions/3.12/bin
  /opt/homebrew/opt/qemu/bin
  $path
)

# =========================================================
# Tool Initialization
# =========================================================

# rbenv (only if installed)
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - zsh)"
fi

# Bun completions (lightweight)
[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"

# =========================================================
# Aliases (high-value only)
# =========================================================
alias ls="eza --icons"
alias ll="eza -lah --icons --git"
alias tree="eza --tree --level=2 --icons"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias c="clear"

alias f="fd"
alias ff="fd -t f"
alias fdg="fd -t d"
alias rg="rg --hidden --glob '!.git'"
alias grep="rg"

alias copy="pbcopy"
alias paste="pbpaste"

alias ports="lsof -i -P | grep LISTEN"
alias psg="ps aux | grep -v grep | grep -i"
alias mem="top -l 1 | head -n 10"
alias dfh="df -h"

alias devices="xcrun simctl list devices"

alias ip="curl ifconfig.me"
alias localip="ipconfig getifaddr en0"
alias serve="python3 -m http.server 8000"

alias vim="nvim"
# =========================================================
# Misc Cleanup
# =========================================================
unset _VOLTA_TOOL_RECURSION

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(zoxide init zsh)"

# This enables Ghostty-specific features like working directory reporting
if [[ -n "$GHOSTTY_RESOURCES_DIR" && -f "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration.zsh" ]]; then
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration.zsh"
fi

# bun completions
[ -s "/Users/seishin/.bun/_bun" ] && source "/Users/seishin/.bun/_bun"

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/seishin/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH=$PATH:$HOME/.maestro/bin

# Force High Contrast Themes for Goose
# 'Monokai Extended' is high-contrast dark, 'GitHub' is high-contrast light.
export GOOSE_CLI_THEME="dark"
export GOOSE_CLI_DARK_THEME="Monokai Extended"
export GOOSE_CLI_LIGHT_THEME="GitHub"

# Disable any automatic theme switching for Goose
unset FZF_DEFAULT_OPTS

. "$HOME/.local/bin/env"

# opencode
export PATH=/Users/seishin/.opencode/bin:$PATH

# Google Cloud SDK
if [ -f "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc" ]; then
  source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc" ]; then
  source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"
fi

# cmux: recreate closed workspace tabs from config
alias ct="cmux-restore"
