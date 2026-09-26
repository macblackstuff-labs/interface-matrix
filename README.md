# interface-matrix

[![Tests](https://github.com/macblackstuff/interface-matrix/actions/workflows/tests.yml/badge.svg)](https://github.com/macblackstuff/interface-matrix/actions/workflows/tests.yml)
[![Release](https://img.shields.io/github/v/release/macblackstuff/interface-matrix)](https://github.com/macblackstuff/interface-matrix/releases/latest)
[![License: MIT](https://img.shields.io/github/license/macblackstuff/interface-matrix)](LICENSE)
[![Agent Skill](https://img.shields.io/badge/Agent_Skill-agentskills.io-blue)](https://agentskills.io/specification)

An [Agent Skill](https://agentskills.io/specification) that builds an N² interface matrix
(a design structure matrix) from a Markdown component and interface inventory, and reports
the four finding classes that a sparse interface list hides: missing components, interface
gaps, unconsumed outputs and isolated components, feedback loops, and every component pair
nobody has stated either way.

It is pass 3 of the seven-pass decomposition pipeline shipped by
[`macblackstuff/system-adoption-pipeline`](https://github.com/macblackstuff/system-adoption-pipeline),
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
npx skills add macblackstuff/interface-matrix
```

Pick the agents and scope non-interactively, for example globally for two agents:

```bash
npx skills add macblackstuff/interface-matrix --skill interface-matrix -g -a claude-code -a codex -y
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

CI installs the skill with the [`skills` CLI](https://github.com/vercel-labs/skills) on every push
and pull request, once per agent in its own throwaway home, and runs the 83 tests from each
installed copy. Every agent the CLI supports is covered — 79 at the time of writing (`skills`
1.7.0), of which 77 are installed and tested. The list is read from the CLI at run time, so agents
it gains later are covered automatically. Two agents are excluded, each with a reason recorded in
`.github/scripts/smoke-install.sh`: `eve` and `promptscript` — the CLI reports that neither
supports global skill installation.

Many agents share a global skills directory, so on a real machine one installed copy serves all of
them; CI still installs and tests each agent separately, so a change to any one agent's target is
caught. Paths below are from a real run, relative to `~`:

| Global install path | Agents |
|---|---|
| `~/.agents/skills` | `amp`, `antigravity`, `antigravity-cli`, `cline`, `codex`, `cursor`, `deepagents`, `dexto`, `droid`, `firebender`, `gemini-cli`, `github-copilot`, `kilo`, `kimi-code-cli`, `loaf`, `opencode`, `replit`, `sarvam-code`, `universal`, `warp`, `zed` |
| `~/.zencoder/skills` | `zencoder`, `zenflow` |
| `~/.adal/skills` | `adal` |
| `~/.aider-desk/skills` | `aider-desk` |
| `~/.astrbot/data/skills` | `astrbot` |
| `~/.augment/skills` | `augment` |
| `~/.autohand/skills` | `autohand-code` |
| `~/.bob/skills` | `bob` |
| `~/.claude/skills` | `claude-code` |
| `~/.codeartsdoer/skills` | `codearts-agent` |
| `~/.codebuddy/skills` | `codebuddy` |
| `~/.codeium/windsurf/skills` | `windsurf` |
| `~/.codemaker/skills` | `codemaker` |
| `~/.codestudio/skills` | `codestudio` |
| `~/.commandcode/skills` | `command-code` |
| `~/.config/crush/skills` | `crush` |
| `~/.config/devin/skills` | `devin` |
| `~/.config/goose/skills` | `goose` |
| `~/.config/kimchi/harness/skills` | `kimchi` |
| `~/.continue/skills` | `continue` |
| `~/.forge/skills` | `forgecode` |
| `~/.fx/skills` | `fx` |
| `~/.grok/skills` | `grok` |
| `~/.hermes/skills` | `hermes-agent` |
| `~/.iflow/skills` | `iflow-cli` |
| `~/.inferencesh/skills` | `inference-sh` |
| `~/.jazz/skills` | `jazz` |
| `~/.junie/skills` | `junie` |
| `~/.kiro/skills` | `kiro-cli` |
| `~/.kode/skills` | `kode` |
| `~/.lingma/skills` | `lingma` |
| `~/.mcpjam/skills` | `mcpjam` |
| `~/.minimax/skills` | `minimax-code` |
| `~/.moxby/skills` | `moxby` |
| `~/.mux/skills` | `mux` |
| `~/.neovate/skills` | `neovate` |
| `~/.ona/skills` | `ona` |
| `~/.openclaw/skills` | `openclaw` |
| `~/.openhands/skills` | `openhands` |
| `~/.pi/agent/skills` | `pi` |
| `~/.pochi/skills` | `pochi` |
| `~/.posit/assistant/skills` | `posit-assistant` |
| `~/.qoder-cn/skills` | `qoder-cn` |
| `~/.qoder/skills` | `qoder` |
| `~/.qwen/skills` | `qwen-code` |
| `~/.reasonix/skills` | `reasonix` |
| `~/.roo/skills` | `roo` |
| `~/.rovodev/skills` | `rovodev` |
| `~/.snowflake/cortex/skills` | `cortex` |
| `~/.tabnine/agent/skills` | `tabnine-cli` |
| `~/.terramind/skills` | `terramind` |
| `~/.tinycloud/skills` | `tinycloud` |
| `~/.trae-cn/skills` | `trae-cn` |
| `~/.trae/skills` | `trae` |
| `~/.vibe/skills` | `mistral-vibe` |
| `~/.zcode/skills` | `zcode` |

Tested: the skill installs for each agent and its own test suite passes from the installed copy.
Not tested: each agent's own runtime behaviour when it loads the skill.

The skill itself is harness-neutral: it is a `SKILL.md` plus standard-library Python, with no
agent-specific commands.

## Security

See [`SECURITY.md`](SECURITY.md) for the supported version and how to report a vulnerability
privately.

## License

MIT — see [`LICENSE`](LICENSE). Copyright (c) 2026 macblackstuff.
