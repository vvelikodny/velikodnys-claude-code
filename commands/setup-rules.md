---
name: "setup-rules"
description: "Copy coding rules from the plugin into the current project's .claude/rules/ directory"
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - Grep
---

SETUP RULES
============

Copy rule files from this plugin into the current project's `.claude/rules/` directory.

STEPS
-----

1. Find the plugin's rules directory. It is located at `${CLAUDE_PLUGIN_ROOT}/rules/`.
   List all available rule files:

```bash
find "${CLAUDE_PLUGIN_ROOT}/rules" -name "*.md" -type f | sort
```

2. Show the user the list of available rules grouped by category:
   - **meta/**: Rules about writing CLAUDE.md
   - **coding/**: Git commits, FastAPI, Kubernetes YAML, Node.js, YAML, Python, Rust
   - **docs/**: Markdown formatting, changelog

3. Ask the user which rules to install:
   - **All rules** — copy everything
   - **By category** — let the user pick categories (meta, coding, docs)
   - **Individual files** — let the user pick specific files

4. For each selected rule file, copy it to the project's `.claude/rules/` directory,
   preserving the subdirectory structure:

```bash
mkdir -p .claude/rules/coding/python .claude/rules/coding/rust .claude/rules/docs .claude/rules/meta
```

5. Copy files using the Read and Write tools (not `cp`) to ensure proper permissions
   and to show the user what's being written.

6. After copying, show a summary of what was installed:
   - Number of rule files copied
   - List of paths created under `.claude/rules/`

IMPORTANT
---------

- Do NOT overwrite existing rule files without asking the user first.
- If a rule file already exists in the project, show a diff and ask whether to replace it.
- The rules directory in this plugin is the SOURCE. The project's `.claude/rules/` is the DESTINATION.
