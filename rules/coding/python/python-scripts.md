---
doc_type: policy
lang: en
tags: ['scripts', 'bash', 'python', 'automation']
last_modified: 2026-02-11T20:10:38Z
paths:
  - 'scripts/**/*'
---

SCRIPT WRITING RULES
====================

TL;DR: Use Bash for small, linear orchestration of existing CLI tools.
Use Python for anything that parses data, needs structure, or should be tested.

DECISION MATRIX
===============

Trait                     | Prefer Bash                               | Prefer Python
------------------------- | ---------------------------------------- | ----------------------------------------
Primary job               | Glue existing CLIs                        | Implement logic, transform data
Control flow              | Mostly linear, few branches               | Complex branching, state, retries
Data handling             | No structured parsing; at most 1 `jq -r`  | JSON/YAML/CSV/log parsing or generation
Error handling            | Fail fast, simple cleanup                 | Timeouts, backoff, partial failures
Portability               | Bash guaranteed (CI/Linux/macOS)          | Cross-platform (especially Windows)
Tests                     | Not worth unit tests                      | Unit tests are expected/required

USE BASH WHEN
=============

- The script is a thin wrapper around an existing CLI (kubectl, docker, terraform, git).
- The work is mostly: run command A, then B, then C, with simple conditionals.
- You can keep it small (roughly <50 lines) and still readable.
- You are not parsing structured data (JSON/YAML) to drive decisions (one-off `jq -r` extraction is OK).
- Bash is guaranteed in the runtime environment (CI runners, Linux containers).
- If Windows is a target runtime, prefer Python instead of Bash.

USE PYTHON WHEN
===============

- You want or need unit tests (non-trivial logic, safety checks, parsing).
- You are parsing or generating JSON/YAML/CSV/logs.
- You need robust error handling (retries with backoff, timeouts, cleanup, state).
- The script has many flags/subcommands or will be reused as a library later.
- The script must run on Windows or mixed environments.

RULE OF THUMB
=============

If correctness matters enough that you'd write a unit test, write the script in Python.

BASH MINIMUM STANDARDS
======================

- Use `#!/usr/bin/env bash` and target Bash explicitly (do not rely on POSIX sh behavior).
- Enable strict mode and a safe IFS.
- Quote all variable expansions unless you explicitly want word-splitting or globbing.
- Use arrays for command arguments; do not build shell commands as strings.
- Do not parse JSON/YAML with grep/sed/awk; if you must read JSON, use `jq` and keep it trivial.
- Avoid `eval` and `xargs` without `-0`.
- Validate required tools up front (for example: `command -v kubectl >/dev/null`).
- Use `mktemp` for temp files and clean up with `trap`.
- Bash scripts should pass ShellCheck (do not disable warnings unless you can justify them).

ShellCheck example:

```bash
shellcheck scripts/path/to/script.sh
```

Recommended header for new scripts:

```text
#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
```

PYTHON MINIMUM STANDARDS
========================

- Use `python3` (Python 3 only). Do not write new scripts that require Python 2.
- Put all logic behind a `main()` function and use an explicit process exit code.
- Use `argparse` for CLI flags and a helpful `--help` message.
- Use `pathlib.Path` for filesystem paths.
- Use `subprocess.run([...], check=True, text=True)` for calling CLIs.
- Avoid `shell=True` unless you must, and never pass untrusted input into a shell command.
- Add type hints for non-trivial functions and keep side effects at the edges.
- Prefer the standard library; if you add third-party deps, declare them in the project's dependency mechanism.
- Separate pure logic from side effects so tests can run without touching the network or filesystem.

Recommended skeleton for new scripts:

```python
import argparse
import logging
import subprocess
import sys
from collections.abc import Sequence
from pathlib import Path
log = logging.getLogger(__name__)


def run(cmd: Sequence[str], *, cwd: Path | None = None) -> str:
    result = subprocess.run(
        list(cmd),
        check=True,
        text=True,
        capture_output=True,
        cwd=str(cwd) if cwd else None,
    )
    if result.stderr:
        log.debug("stderr: %s", result.stderr.rstrip())
    return result.stdout


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Example script skeleton")
    parser.add_argument("--repo", type=Path, default=Path.cwd())
    parser.add_argument("-v", "--verbose", action="count", default=0)
    args = parser.parse_args(argv)

    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(levelname)s: %(message)s",
    )

    try:
        output = run(["git", "status", "--porcelain=v1"], cwd=args.repo)
    except subprocess.CalledProcessError as e:
        print(e.stderr or str(e), file=sys.stderr, end="")
        return e.returncode

    print(output, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

OUTPUT AND UX
=============

- Be non-interactive by default.
- Print the intended result to stdout.
- Send diagnostics/logs to stderr.
- Keep output stable (avoid spinners, prompts, and noisy progress in CI).
- For mutating operations, support `--dry-run` when practical.

CHECKLIST
=========

- This script is only orchestration of existing CLIs; otherwise choose Python.
- Bash scripts use strict mode, quote variables, avoid structured parsing, and pass ShellCheck.
- Python scripts use `argparse`, safe `subprocess.run`, and return explicit exit codes.
- Non-trivial Python scripts have tests with side effects mocked/injected.
- Script output is stable, readable, and pipe-friendly.
