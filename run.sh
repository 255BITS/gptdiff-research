#!/usr/bin/env bash
# Loops gptdiff on this folder until you Ctrl-C.
#
# Usage:
#   ./run.sh                       # loop forever
#   ITERS=5 ./run.sh               # stop after 5 iterations
#   MODEL=gpt-5.2 ./run.sh         # override the model in .env

set -u

cd "$(dirname "${BASH_SOURCE[0]}")"

# Load .env if the key isn't already in the environment.
if [[ -z "${GPTDIFF_LLM_API_KEY:-}" && -f .env ]]; then
  set -a; source ./.env; set +a
fi

if [[ -z "${GPTDIFF_LLM_API_KEY:-}" ]]; then
  echo "ERROR: GPTDIFF_LLM_API_KEY not set. Copy .env.example to .env and fill it in." >&2
  exit 1
fi

MODEL_FLAG=()
[[ -n "${MODEL:-}" ]] && MODEL_FLAG=(--model "$MODEL")

PROMPT='Read the `about` file. Pick one book to give each person as a
holiday gift, plus one for me to read myself. Write the picks (one or two
lines of reasoning per person) to a file called `suggestions`. Improve
`suggestions` if it already exists — keep what works, swap what does not.'

i=0
LIMIT="${ITERS:-0}"

while true; do
  i=$((i+1))
  echo "=== iteration $i ==="
  gptdiff "$PROMPT" --apply --verbose "${MODEL_FLAG[@]}"

  if [[ "$LIMIT" -gt 0 && "$i" -ge "$LIMIT" ]]; then
    echo "=== stopped after $LIMIT iterations ==="
    break
  fi
done
