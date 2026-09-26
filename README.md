# interface-matrix

An [Agent Skill](https://agentskills.io/specification) that builds an N² interface matrix
(a design structure matrix) from a Markdown component and interface inventory, and reports
the four finding classes that a sparse interface list hides: missing components, interface
gaps, unconsumed outputs and isolated components, feedback loops, and every component pair
nobody has stated either way.

It is pass 3 of the seven-pass decomposition pipeline shipped by
[`macblackstuff-labs/system-adoption-pipeline`](https://github.com/macblackstuff-labs/system-adoption-pipeline),
and useful on its own for planning or auditing a system of roughly eight or more components.

| Path | What it is |
|---|---|
| [`skills/interface-matrix/SKILL.md`](skills/interface-matrix/SKILL.md) | The procedure an agent follows: input format, run, mandatory human review, how to resolve each finding. |
| [`skills/interface-matrix/scripts/interface_matrix.py`](skills/interface-matrix/scripts/interface_matrix.py) | The report generator. |
| [`skills/interface-matrix/scripts/test_interface_matrix.py`](skills/interface-matrix/scripts/test_interface_matrix.py) | Its self-check — 83 tests. |
| [`skills/interface-matrix/references/RUNBOOK.md`](skills/interface-matrix/references/RUNBOOK.md) | Operating it: health checks, every error message and its fix, rollback, escalation. |

## Install

With the [`skills` CLI](https://github.com/vercel-labs/skills):

```bash
npx skills add macblackstuff-labs/interface-matrix
```

While this repository is private, the CLI needs a GitHub token to read it: export `GH_TOKEN` (for
example from an authenticated GitHub CLI, `export GH_TOKEN=$(gh auth token)`) before running it.

Pick the agents and scope non-interactively, for example globally for two agents:

```bash
npx skills add macblackstuff-labs/interface-matrix --skill interface-matrix -g -a claude-code -a codex -y
```

Or copy the folder into wherever your agent reads skills from, keeping its internal layout:

```bash
cp -R skills/interface-matrix /path/to/your/skills/
```

Every path inside the skill is relative to its own folder, so the destination does not matter.
Verify the install from inside the installed folder:

```bash
python3 scripts/test_interface_matrix.py    # Ran 83 tests ... OK
```

## Requirements

Python 3.9 or newer. Standard library only — no dependencies, no virtualenv, no install step.

On Windows the interpreter is usually `py` rather than `python3`, so read `py` for `python3` in
every command below.

## Harnesses tested

CI installs the skill with the `skills` CLI on every push and pull request, once per agent, and
runs the 83 tests from each installed copy. Six agents are covered: `claude-code`, `codex`,
`cursor`, `gemini-cli`, `github-copilot` and `opencode`. Five of the six share one user-level skills
directory (the `skills` CLI decides the target; see its documentation for each agent's path), so
on a real machine a single installed copy can serve all five. CI still installs and tests each
agent separately, in its own throwaway home, so a change to any one agent's target is caught.

The skill itself is harness-neutral: it is a `SKILL.md` plus standard-library Python, with no
agent-specific commands.

## Security

See [`SECURITY.md`](SECURITY.md) for the supported version and how to report a vulnerability
privately.

## License

MIT — see [`LICENSE`](LICENSE). Copyright (c) 2026 macblackstuff-labs.
