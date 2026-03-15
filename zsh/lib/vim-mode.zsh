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
    # Block cursor in normal mode
    echo -ne '\e[2 q'
  else
    # Beam cursor in insert mode
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

# Initialize with beam cursor
function zle-line-init {
  echo -ne '\e[5 q'
}
zle -N zle-line-init

# ==========================================
# System Clipboard Integration
# ==========================================

# Copy yanked text to system clipboard (macOS pbcopy)
function zsh-vi-yank-to-clipboard {
  # Get the text from zsh's cut buffer
  local cut_text="$(echo "$CUTBUFFER" | head -c 10000)"
  
  # Copy to system clipboard using pbcopy
  if [[ -n "$cut_text" ]]; then
    echo -n "$cut_text" | pbcopy 2>/dev/null
  fi
  
  # Call the original yank function
  zle .vi-yank
}
zle -N zsh-vi-yank-to-clipboard

# Copy entire line to system clipboard
function zsh-vi-yank-whole-line-to-clipboard {
  # Copy current line to clipboard
  local line_text="$BUFFER"
  if [[ -n "$line_text" ]]; then
    echo -n "$line_text" | pbcopy 2>/dev/null
  fi
  
  # Call the original function
  zle .vi-yank-whole-line
}
zle -N zsh-vi-yank-whole-line-to-clipboard

# Copy visual selection to system clipboard  
function zsh-vi-visual-yank-to-clipboard {
  # Copy selected text to clipboard
  local visual_text="${CUTBUFFER:-$REGION_ACTIVE}"
  if [[ -n "$CUTBUFFER" ]]; then
    echo -n "$CUTBUFFER" | pbcopy 2>/dev/null
  fi
  
  # Call the original function
  zle .vi-visual-yank
}
zle -N zsh-vi-visual-yank-to-clipboard

# Override yank keys to use clipboard versions
bindkey -M vicmd 'y' zsh-vi-yank-to-clipboard
bindkey -M vicmd 'Y' zsh-vi-yank-whole-line-to-clipboard

# Visual mode yank
bindkey -M visual 'y' zsh-vi-visual-yank-to-clipboard

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

# Allow Ctrl+R for history search in insert mode
bindkey "^R" history-incremental-search-backward

# Fix backspace in vi mode
bindkey "^?" backward-delete-char
bindkey "^H" backward-delete-char

# Paste from system clipboard
function zsh-vi-put-from-clipboard {
  local clipboard_content
  clipboard_content=$(pbpaste 2>/dev/null)
  if [[ -n "$clipboard_content" ]]; then
    LBUFFER="${LBUFFER}${clipboard_content}"
  fi
}
zle -N zsh-vi-put-from-clipboard

# p to paste from system clipboard
bindkey -M vicmd 'p' zsh-vi-put-from-clipboard
