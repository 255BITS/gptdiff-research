# gptdiff-research: the gift-picker example

A 5-minute example of using [**gptdiff**](https://github.com/255BITS/gptdiff)
to iteratively improve a file by running the same prompt in a loop.

`gptdiff` is a command-line tool. You give it a prompt; it reads every file
in the current directory, asks an AI to write a diff that changes those
files, and applies the diff. Run it in a loop and the AI sees its own
previous output each pass — so it keeps refining.

This example uses that pattern to pick books to give as holiday gifts.

---

## Run it

```bash
git clone https://github.com/255BITS/gptdiff-research
cd gptdiff-research

pip install -r requirements.txt        # installs gptdiff

cp .env.example .env                   # put your API key in .env
$EDITOR .env

./run.sh                               # Ctrl-C when you're happy
```

You need an LLM API key. The default in `.env.example` points at
[ai.bitcoin.com](https://ai.bitcoin.com/api) — one key, many models. You can
swap in OpenAI / Anthropic / OpenRouter by changing the URL in `.env`.

---

## What you'll see

The first iteration writes a `suggestions` file with a book pick for each
person in `about`. The second iteration reads that file and rewrites it —
usually changing a pick or two. By iteration 5–10 the picks settle.

Watch it work:

```bash
# in another terminal, while run.sh is looping
watch -d cat suggestions
```

Or use `git`:

```bash
git diff suggestions                   # what the last pass changed
```

Stop the loop with **Ctrl-C** when the picks look good. To start over,
`rm suggestions` and run again.

---

## How it works

One iteration looks like this:

```
[ about + (current) suggestions ]  →  AI  →  diff  →  applied
```

`gptdiff` sends every text file in this folder (except things listed in
`.gitignore` and `.gptignore`) to the AI. The AI returns a unified diff.
`--apply` applies it. The loop runs that over and over.

Files in this folder:

| file              | role                                                |
|-------------------|-----------------------------------------------------|
| `about`           | **You edit this.** Describes the people.            |
| `suggestions`     | **AI writes this.** The current best picks.         |
| `run.sh`          | The loop.                                           |
| `.env`            | API key + model choice.                             |
| `.gptignore`      | Files the AI doesn't see (README, scripts, .env).   |

If you want to steer the loop, edit `about` — add a constraint, change a
taste, mention a budget. The next iteration will pick it up.

---

## Use this for bigger problems

The loop is tiny but the pattern scales. Anywhere you'd otherwise sit and
think through a hard, fuzzy problem with no obvious answer:

1. **One input file** describes the situation (people, constraints,
   goal). Keep it short.
2. **One output file** is what you want the AI to produce — a design, a
   plan, a shortlist, a strategy doc.
3. **One prompt** asks the AI to *improve* the output file given the input.
   Not "write from scratch" — "improve." That word makes iteration N+1
   refine iteration N instead of starting over.
4. **Loop with `--apply`.** Each pass sees the previous pass's output.
5. **Steer by editing the input file.** Don't rewrite the prompt — add a
   missing constraint to `about` and let the loop respond.
6. **Switch the model when stuck.** `MODEL=gpt-5.2 ./run.sh` then
   `MODEL=claude-opus-4-5 ./run.sh`. Different models converge on
   different answers; running two is often more useful than running one
   for twice as long.
7. **Stop when it stops improving.** Ctrl-C is the success criterion.

Good fit: picking, planning, designing, naming, comparing, drafting.

---

## Credits

[gptdiff](https://github.com/255BITS/gptdiff) by 255BITS.
