export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"

if [[ -r "$CARGO_HOME/env" ]]; then
  . "$CARGO_HOME/env"
fi
