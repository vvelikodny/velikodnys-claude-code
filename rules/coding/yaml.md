---
doc_type: policy
lang: en
tags: ['yaml', 'formatting', 'yamllint']
last_modified: 2026-02-12T15:00:00Z
paths:
  - '**/*.yml'
  - '**/*.yaml'
---

YAML FORMATTING RULES
=====================

TL;DR: Use 2-space indentation, spaces only (no tabs).
Run `make lint` (or `yamllint -c .yamllint.yml .`) before committing YAML changes.
Do not reformat vendored/upstream YAML just to satisfy style; keep diffs minimal.

INDENTATION AND WHITESPACE
==========================

2-space indentation
-------------------

- Use 2 spaces per indentation level in project-owned YAML.
- Do not use tabs. Tabs are invalid in YAML indentation.
- Do not use "indentless" sequences. Always indent list items under their parent key.
- If `.yamllint.yml` enables `document-start`, begin each YAML document with `---`.

CORRECT (indented sequence items):
```yaml
containers:
  - name: api
    ports:
      - name: http
        containerPort: 8080
```

WRONG (indentless sequence items):
```yaml
containers:
- name: api
  ports:
    - name: http
```

Upstream/vendored YAML
----------------------

- Do not reindent or rewrap upstream files (Helm charts, vendor dirs) just to match style.
- Only change formatting when making a functional change in the same hunk.
- If an upstream directory fails `yamllint`, add an ignore pattern in `.yamllint.yml`
  rather than mass-reformatting.

Trailing whitespace and final newline
-------------------------------------

- Remove trailing spaces and tabs.
- Ensure files end with a single newline.

Quick check before commit:
```bash
git diff --check
```

Recommended `.editorconfig`:
```text
[*.{yml,yaml}]
indent_style = space
indent_size = 2
trim_trailing_whitespace = true
insert_final_newline = true
```

IMPLICIT TYPING
===============

YAML parsers infer types. A value that looks like a boolean, number, or null
will be parsed as one — even if the consumer expects a string.

- Quote values that must remain strings but look like booleans or numbers.
- Be explicit about null (`key:`) vs empty string (`key: ""`).

MULTI-LINE STRINGS
==================

- Use `|-` for content where newlines matter (config files, scripts, certificates).
- Use `>-` for long text where newlines should fold into spaces.
- Prefer chomp indicator (`|-` / `>-`) to avoid accidental trailing newline.

Example:
```yaml
config: |-
  [server]
  listen = 0.0.0.0:8080

  [logging]
  level = info
```

LONG LINES AND UNBREAKABLE STRINGS
===================================

- Do not wrap unbreakable scalars (digests, base64 blobs, URLs, tokens).
- If a line-length rule complains, use a targeted linter exception.
- For long human-readable text, use folded block scalars (`>-`).

YAMLLINT
========

`.yamllint.yml` is the source of truth. Do not guess rules from memory.

Run before committing YAML changes:
```bash
make lint
```

If `make lint` is unavailable:
```bash
yamllint -c .yamllint.yml .
```

CHECKLIST
=========

- 2-space indentation (spaces only, no tabs)
- No indentless sequences
- No trailing whitespace; file ends with a newline
- String values that look numeric/boolean are quoted
- `yamllint` passes via `make lint`
