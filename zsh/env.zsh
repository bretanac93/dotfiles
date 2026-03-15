export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"

if [[ -r "$CARGO_HOME/env" ]]; then
  . "$CARGO_HOME/env"
fi

# Disable 1Password SSH agent - use local keys only
# This ensures SSH uses ~/.ssh/ keys directly instead of 1Password agent
if [[ "$SSH_AUTH_SOCK" == *"1password"* ]] || [[ "$SSH_AUTH_SOCK" == *"com.1password"* ]]; then
  unset SSH_AUTH_SOCK
fi
