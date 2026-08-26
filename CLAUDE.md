@AGENTS.md

Claude Code specific: prefer ripgrep over find. When asked a question
that spans workstreams, search `/concepts/` and `/decisions/` before
`/meetings/`.

Use the `gh` CLI for the open-pull-request sweep the read protocol asks
for, and read a PR with `gh pr diff <n>` rather than checking its branch
out — a checkout moves the user off the branch they were working on.

If the sweep turns up a PR that already makes your change, stop and tell
the user its number and author — do not `git cherry-pick` it or retype it
out of the diff. Run `python3 tools/check_queue.py` to check that no open
PR has already been landed that way.

Run `python3 tools/check_gh.py` before that sweep. If it exits non-zero,
relay the reason and remedy it prints and offer to walk the user through
the fix — do not quietly fall back to searching the working tree.

When it reports `gh` is missing or too old, it prints the install command
for this machine. Show it, say what it will do, and ask before running it.
Never run a `sudo` line yourself — ask the user to run it with `! <command>`
so the output lands in this session, then re-run the preflight.

`gh auth login` is interactive and you cannot complete it. Ask the user to
run it themselves by typing `! gh auth login` in the prompt, so its output
lands in this session, then re-run the preflight before sweeping.
