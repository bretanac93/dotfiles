# Syntax highlighting with opportunistic loading
# Tries to find zsh-fast-syntax-highlighting from multiple sources

local -a fsh_paths=(
  # Manual install
  "${ZSH_CONFIG_DIR:-$HOME/.config/zsh}/third-party/fast-syntax-highlighting"
  # macOS Apple Silicon Homebrew
  "/opt/homebrew/share/zsh-fast-syntax-highlighting"
  # Arch system package
  "/usr/share/zsh/plugins/fast-syntax-highlighting"
)

local fsh_path
local fsh_loaded=0

for fsh_path in $fsh_paths; do
  if [[ -r "$fsh_path/fast-syntax-highlighting.plugin.zsh" ]]; then
    source "$fsh_path/fast-syntax-highlighting.plugin.zsh"
    fsh_loaded=1
    break
  fi
done

# If not found in standard paths, check if HOMEBREW_PREFIX is set
if (( ! fsh_loaded )) && [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  local brew_fsh="$HOMEBREW_PREFIX/share/zsh-fast-syntax-highlighting"
  if [[ -r "$brew_fsh/fast-syntax-highlighting.plugin.zsh" ]]; then
    source "$brew_fsh/fast-syntax-highlighting.plugin.zsh"
  fi
fi
