# Contributing to interface-matrix

Bug reports, fixes and documentation improvements are welcome.

## Before you start

- Search [existing issues](https://github.com/macblackstuff/interface-matrix/issues) first.
- For anything larger than a small fix, open an issue describing the change before writing code.
- Security problems go through [private vulnerability reporting](SECURITY.md), never a public issue.

## Development setup

The skill needs Python 3.9 or newer and nothing else: standard library only, no install step.

```bash
git clone https://github.com/macblackstuff/interface-matrix.git
cd interface-matrix/skills/interface-matrix
python3 scripts/test_interface_matrix.py
python3 -O scripts/test_interface_matrix.py
```

Every run must pass, with and without `-O`.

## What CI checks

Every pull request runs these checks, and all of them must pass before merge:

| Check | What it enforces |
|---|---|
| `tests (3.9)`, `tests (3.x)` | the self-test above, on the oldest supported and the newest Python |
| `spec` | `SKILL.md` passes [`skills-ref validate`](https://github.com/agentskills/agentskills) |
| `install` | the [`skills` CLI](https://github.com/vercel-labs/skills) installs the skill for six agents |
| `commit-emails` | every commit uses a GitHub noreply address |

## Commit email

The email check rejects any commit whose author or committer address is not a GitHub noreply
address (`<id>+<username>@users.noreply.github.com`). Find yours at
[github.com/settings/emails](https://github.com/settings/emails), then set it for this clone:

```bash
git config user.email "<id>+<username>@users.noreply.github.com"
```

## Pull requests

- One change per pull request, with a test that fails without it (documentation-only changes excepted).
- Add a line to `CHANGELOG.md` under an `Unreleased` heading.
- Update `SKILL.md` or `references/` when behaviour the agent sees changes.
- Pull requests are squash-merged and the title becomes the commit subject, so write it as one.

## Downstream copy

[system-adoption-pipeline](https://github.com/macblackstuff/system-adoption-pipeline) vendors
`scripts/interface_matrix.py` and `scripts/test_interface_matrix.py`, pinned by sha256. A change
merged here reaches the pipeline only when it re-vendors a tagged release of this repository.

## Code of conduct

This project follows the [Contributor Covenant 2.1](CODE_OF_CONDUCT.md). Report unacceptable
behaviour to [conduct@macblackstuff.com](mailto:conduct@macblackstuff.com).

## License

By contributing you agree that your contribution is licensed under the [MIT License](LICENSE).
