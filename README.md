# gptdiff-research

Short examples of using [**gptdiff**](https://github.com/255BITS/gptdiff)
to iteratively improve a file by running the same prompt in a loop.

`gptdiff` is a command-line tool. You give it a prompt; it reads every file
in a directory, asks an AI to write a diff that changes those files, and
applies the diff. Run it in a loop and the AI sees its own previous output
each pass — so it keeps refining.

Each example lives in its own subdirectory:

| directory | what it does                                                 |
|-----------|--------------------------------------------------------------|
| `gifts/`  | Picks books to give as holiday gifts based on people's tastes. |

---

## Run it

```bash
git clone https://github.com/255BITS/gptdiff-research
cd gptdiff-research

pip install -r requirements.txt        # installs gptdiff

cp .env.example .env                   # put your API key in .env
$EDITOR .env

./run.sh gifts                         # Ctrl-C when you're happy
```

You need an LLM API key. The default in `.env.example` points at
[ai.bitcoin.com](https://ai.bitcoin.com/api) — one key, many models. You can
swap in OpenAI / Anthropic / OpenRouter by changing the URL in `.env`.

---

## What you'll see

`./run.sh gifts` reads `gifts/prompt` and runs that prompt against the
contents of `gifts/` in a loop.

The first iteration writes a `gifts/suggestions` file with a book pick for
each person in `gifts/about`. The second iteration reads that file and
rewrites it — usually changing a pick or two. By iteration 5–10 the picks
settle.

Watch it work:

```bash
# in another terminal, while run.sh is looping
watch -d cat gifts/suggestions
```

Or use `git`:

```bash
git -C gifts diff suggestions          # what the last pass changed
```

Stop the loop with **Ctrl-C** when the picks look good. To start over,
`rm gifts/suggestions` and run again.

---

## How it works

`run.sh <directory>` does this each iteration:

```
[ everything in <directory> ]  →  AI  →  diff  →  applied to <directory>
```

`gptdiff` sees every text file in the target directory **except** anything
listed in `.gitignore` or `.gptignore`. It returns a unified diff and
`--apply` applies it.

The shape of an example directory:

| file in dir       | role                                                     |
|-------------------|----------------------------------------------------------|
| `prompt`          | The instruction sent to the AI each iteration.           |
| `about` (or any name) | **You edit this.** Context the AI reads.             |
| `suggestions` (or any name) | **AI writes this.** Whatever output you ask for. |
| `.gptignore`      | At minimum, ignores `prompt` so the AI can't rewrite its own instructions. |

If you want to steer the loop, edit `gifts/about` — add a constraint,
change a taste, mention a budget. The next iteration picks it up.

---

## Make your own example

Drop a new directory at the top level with two files:

```
myexample/
├── prompt          # one paragraph: what should the AI write/improve, and to what file?
├── about           # the context the AI needs (call it whatever you want)
└── .gptignore      # one line: `prompt`
```

Then:

```bash
./run.sh myexample
```

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
   missing constraint to the input file and let the loop respond.
6. **Switch the model when stuck.** `MODEL=gpt-5.2 ./run.sh gifts` then
   `MODEL=claude-opus-4-5 ./run.sh gifts`. Different models converge on
   different answers; running two is often more useful than running one
   for twice as long.
7. **Stop when it stops improving.** Ctrl-C is the success criterion.

Good fit: picking, planning, designing, naming, comparing, drafting.

---

## Credits

[gptdiff](https://github.com/255BITS/gptdiff) by 255BITS.
