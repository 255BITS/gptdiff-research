#!/usr/bin/env bash
# Loop gptdiff on an example directory until you Ctrl-C.
#
# Each example directory contains:
#   - a `prompt` file       (the instruction sent to the AI each iteration)
#   - any context files     (the AI reads + edits these)
#   - a `.gptignore`        (at minimum: ignores `prompt` so the AI cannot rewrite its own instructions)
#
# Usage:
#   ./run.sh gifts                 # loop on ./gifts
#   ITERS=5 ./run.sh gifts         # stop after 5 iterations
#   MODEL=gpt-5.2 ./run.sh gifts   # override the model in .env

set -u

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <example-directory>" >&2
  exit 1
fi

DIR="$1"

if [[ ! -d "$DIR" ]]; then
  echo "ERROR: '$DIR' is not a directory." >&2
  exit 1
fi
if [[ ! -f "$DIR/prompt" ]]; then
  echo "ERROR: '$DIR/prompt' not found. Each example directory needs a 'prompt' file." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="$(cd "$DIR" && pwd)"

# Load .env from the script directory if the key isn't already in the environment.
if [[ -z "${GPTDIFF_LLM_API_KEY:-}" && -f "$SCRIPT_DIR/.env" ]]; then
  set -a; source "$SCRIPT_DIR/.env"; set +a
fi

if [[ -z "${GPTDIFF_LLM_API_KEY:-}" ]]; then
  echo "ERROR: GPTDIFF_LLM_API_KEY not set. Copy .env.example to .env and fill it in." >&2
  exit 1
fi

MODEL_FLAG=()
[[ -n "${MODEL:-}" ]] && MODEL_FLAG=(--model "$MODEL")

PROMPT="$(cat "$DIR/prompt")"

cd "$DIR"

i=0
LIMIT="${ITERS:-0}"

while true; do
  i=$((i+1))
  echo "=== iteration $i ($(basename "$DIR")) ==="
  gptdiff "$PROMPT" --apply --verbose "${MODEL_FLAG[@]}"

  if [[ "$LIMIT" -gt 0 && "$i" -ge "$LIMIT" ]]; then
    echo "=== stopped after $LIMIT iterations ==="
    break
  fi
done
