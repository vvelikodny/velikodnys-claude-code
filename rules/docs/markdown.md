---
doc_type: policy
lang: en
tags: ['markdown', 'formatting', 'documentation']
last_modified: 2026-02-22T12:00:00Z
---

MARKDOWN FILE RULES
===================

TL;DR: YAML frontmatter required. TL;DR section after header. CAPS headers with === underlines.
Keep formatting minimal — flat lists, no nesting, no heavy markup. Max 120 chars per line.
Update last_modified on every change.

REQUIRED ELEMENTS
=================

YAML frontmatter
-----------------

Every .md file MUST start with YAML front matter:

```yaml
---
doc_type: policy
tags: ['topic1', 'topic2']
last_modified: 2026-02-12T17:00:00Z
---
```

Required fields:
- `doc_type` — document type (policy, reference, guide, meta)
- `tags` — search tags, max 5
- `last_modified` — ISO 8601, MUST be updated on every change

TL;DR section
--------------

MUST follow immediately after the main header. 3-5 lines.
Summarize the essence — what a reader needs to know before reading further.

HEADERS
=======

- Main headers: CAPS with `===` underline
- Subheaders: normal case with `---` underline
- Level 3: normal case with `...` underline

```text
MAIN HEADER
===========

Subheader
---------

Sub-subheader
.............
```

FORMATTING
==========

Keep it minimal
---------------

- Flat lists with `-` only. No nested lists.
- No bold, italic, or strikethrough in running text.
- Inline `code` for commands, params, filenames — this is fine.
- Plain URLs, no markdown link syntax.
- Code blocks with language tag required.

Line length
-----------

Max 120 characters. Break long lines.

Bash code blocks
----------------

- Max 2 lines per block (combine with `&&` if needed).
- No comments inside bash blocks — put them before the block.

```bash
make build && make test
```

CHECKLIST
=========

- YAML frontmatter present, last_modified updated
- TL;DR section present (3-5 lines)
- CAPS headers with === underlines
- No nested lists, no heavy formatting
- Code blocks have language tags
- Lines under 120 characters
