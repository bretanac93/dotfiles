# Syntax highlighting with opportunistic loading
# Tries to find fast-syntax-highlighting or syntax-highlighting from multiple sources

local -a fsh_paths=(
  # Manual install (fast version)
  "${ZSH_CONFIG_DIR:-$HOME/.config/zsh}/third-party/fast-syntax-highlighting"
  # macOS Apple Silicon Homebrew (fast version)
  "/opt/homebrew/share/zsh-fast-syntax-highlighting"
  # macOS Apple Silicon Homebrew (standard version)
  "/opt/homebrew/share/zsh-syntax-highlighting"
  # Arch system package (fast version)
  "/usr/share/zsh/plugins/fast-syntax-highlighting"
  # Arch system package (standard version)
  "/usr/share/zsh/plugins/zsh-syntax-highlighting"
  # Debian/Ubuntu standard location
  "/usr/share/zsh-syntax-highlighting"
)

local fsh_path
local fsh_loaded=0

for fsh_path in $fsh_paths; do
  if [[ -r "$fsh_path/fast-syntax-highlighting.plugin.zsh" ]]; then
    source "$fsh_path/fast-syntax-highlighting.plugin.zsh"
    fsh_loaded=1
    break
  elif [[ -r "$fsh_path/zsh-syntax-highlighting.plugin.zsh" ]]; then
    source "$fsh_path/zsh-syntax-highlighting.plugin.zsh"
    fsh_loaded=1
    break
  elif [[ -r "$fsh_path/zsh-syntax-highlighting.zsh" ]]; then
    source "$fsh_path/zsh-syntax-highlighting.zsh"
    fsh_loaded=1
    break
  fi
done

# If not found in standard paths, check if HOMEBREW_PREFIX is set
if (( ! fsh_loaded )) && [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  local brew_fsh_fast="$HOMEBREW_PREFIX/share/zsh-fast-syntax-highlighting"
  local brew_fsh_std="$HOMEBREW_PREFIX/share/zsh-syntax-highlighting"
  
  if [[ -r "$brew_fsh_fast/fast-syntax-highlighting.plugin.zsh" ]]; then
    source "$brew_fsh_fast/fast-syntax-highlighting.plugin.zsh"
  elif [[ -r "$brew_fsh_std/zsh-syntax-highlighting.plugin.zsh" ]]; then
    source "$brew_fsh_std/zsh-syntax-highlighting.plugin.zsh"
  fi
fi

