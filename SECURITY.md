# Security policy

## Supported version

Only the latest release is supported. The first release is v0.1.0. Fixes are published as a new
release; older tags do not receive backports.

## Reporting a vulnerability

Report it privately through GitHub, not in a public issue, pull request or discussion:

1. Open [the repository's Security tab](https://github.com/macblackstuff-labs/interface-matrix/security/advisories/new).
2. Use **Report a vulnerability** to open a private security advisory.

Private vulnerability reporting is enabled, so that link works for anyone. Only the maintainers
can see the advisory. Please include the version or commit, the platform and interpreter version,
what you did, what happened and what you expected, and a minimal input that reproduces it.

Please do not report vulnerabilities by email. GitHub's private advisory is the only channel
that is monitored.

## Scope

This repository ships one Agent Skill: a `SKILL.md` procedure plus standard-library Python
that reads a Markdown inventory and writes a report. It takes no network input, holds no
credentials and runs no code from its input. The reports worth sending are therefore ones
where handling a crafted input file causes something other than an error message — for
example writing outside the requested output path, or unbounded resource use on a small input.

## What to expect

We aim to acknowledge a report within seven days and to say whether we accept it, with an
estimate for a fix, within thirty. Reports declined as out of scope get a reason.
