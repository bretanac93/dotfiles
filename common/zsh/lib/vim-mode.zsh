#!/bin/zsh
#
# Vim mode for zsh command line editing
# Press Esc or Ctrl+[ to enter normal mode
# Press i/a to return to insert mode
#

# Enable vim mode
bindkey -v

# Reduce lag when entering normal mode (100ms)
export KEYTIMEOUT=10

# Better cursor indicators for different modes
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]]; then
    # Normal mode: Block cursor, NOT blinking (steady)
    echo -ne '\e[2 q'
  else
    # Insert mode: Block cursor, BLINKING
    echo -ne '\e[1 q'
  fi
}
zle -N zle-keymap-select

# Initialize with blinking block cursor (insert mode)
function zle-line-init {
  echo -ne '\e[1 q'
}
zle -N zle-line-init

# ==========================================
# System Clipboard Integration
# ==========================================

# Detect once at load time — avoids a hash lookup on every yank/paste
if (( $+commands[pbcopy] )); then
  _ZSH_CLIP_COPY=pbcopy; _ZSH_CLIP_PASTE=pbpaste
elif (( $+commands[wl-copy] )); then
  _ZSH_CLIP_COPY=wl-copy; _ZSH_CLIP_PASTE=wl-paste
fi

function zsh-vi-yank-to-clipboard {
  local cut_text="${CUTBUFFER[1,10000]}"
  [[ -n "$cut_text" && -n "${_ZSH_CLIP_COPY:-}" ]] && print -rn -- "$cut_text" | "$_ZSH_CLIP_COPY" 2>/dev/null
  zle .vi-yank
}
zle -N zsh-vi-yank-to-clipboard

function zsh-vi-yank-whole-line-to-clipboard {
  [[ -n "$BUFFER" && -n "${_ZSH_CLIP_COPY:-}" ]] && print -rn -- "$BUFFER" | "$_ZSH_CLIP_COPY" 2>/dev/null
  zle .vi-yank-whole-line
}
zle -N zsh-vi-yank-whole-line-to-clipboard

bindkey -M vicmd 'y' zsh-vi-yank-to-clipboard
bindkey -M vicmd 'Y' zsh-vi-yank-whole-line-to-clipboard

# ==========================================
# Vim Navigation and Keybindings
# ==========================================

# Vim navigation in normal mode (vicmd)
bindkey -M vicmd 'h' backward-char
bindkey -M vicmd 'j' down-line-or-history
bindkey -M vicmd 'k' up-line-or-history
bindkey -M vicmd 'l' forward-char

# Prevent run-help from triggering on 'h' in normal mode
autoload -Uz run-help 2>/dev/null || true

# Vim-style keybindings in insert mode
bindkey "^A" beginning-of-line          # Ctrl+a: beginning
bindkey "^E" end-of-line                # Ctrl+e: end
bindkey "^K" kill-line                  # Ctrl+k: delete to end
bindkey "^U" backward-kill-line         # Ctrl+u: delete to beginning
bindkey "^W" backward-kill-word         # Ctrl+w: delete word

# Keep Ctrl+R consistent across insert and normal modes.
# Prefer fzf history when the widget is available, otherwise fall back to zsh's
# incremental history search.
if zle -l fzf-history-widget >/dev/null 2>&1; then
  bindkey -M viins "^R" fzf-history-widget
  bindkey -M vicmd "^R" fzf-history-widget
else
  bindkey -M viins "^R" history-incremental-search-backward
  bindkey -M vicmd "^R" history-incremental-search-backward
fi

# Fix backspace in vi mode
bindkey "^?" backward-delete-char
bindkey "^H" backward-delete-char

function zsh-vi-put-from-clipboard {
  local clipboard_content
  [[ -n "${_ZSH_CLIP_PASTE:-}" ]] && clipboard_content=$("$_ZSH_CLIP_PASTE" 2>/dev/null)
  [[ -n "$clipboard_content" ]] && LBUFFER="${LBUFFER}${clipboard_content}"
}
zle -N zsh-vi-put-from-clipboard

# p to paste from system clipboard
bindkey -M vicmd 'p' zsh-vi-put-from-clipboard
