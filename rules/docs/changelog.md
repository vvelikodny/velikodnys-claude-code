---
doc_type: policy
lang: en
tags: ['changelog', 'documentation']
last_modified: 2026-02-22T12:00:00Z
paths:
  - '**/CHANGELOG.md'
---

CHANGELOG RULES
===============

TL;DR: Group changes by date and type (Added, Changed, Fixed, Removed,
Deprecated, Security). No versions, no releases — just dates. Newest first.
Inspired by https://keepachangelog.com/en/1.1.0/

FORMAT
======

Header
------

Every CHANGELOG.md starts directly with the header (no YAML frontmatter):

```markdown
CHANGELOG
=========

All notable changes to this project are documented in this file.
```

Date sections
-------------

Each date is a section header. Dates in ISO 8601: YYYY-MM-DD.

```markdown
2026-02-22
----------

### Added

- OAuth 2.0 login support

### Fixed

- Token refresh loop on expired sessions

2026-02-20
----------

### Changed

- Increase default timeout to 30s
```

- Newest date first, oldest last
- Group all changes for the same date under one section

CHANGE TYPES
============

Group changes under these categories (only include categories that have entries):

- `Added` — new features
- `Changed` — changes in existing functionality
- `Deprecated` — soon-to-be removed features
- `Removed` — removed features
- `Fixed` — bug fixes
- `Security` — vulnerability fixes

ENTRY RULES
===========

- One line per change, start with `-`
- Describe the change from the user's perspective, not implementation details
- Reference issues or PRs where relevant: `(#123)`
- Do NOT dump git log into the changelog — curate notable changes only
- Do NOT leave empty categories — omit categories with no entries

WHEN TO UPDATE
==============

- Add entries on every commit, grouped under today's date
- If today's date section already exists, add to it
- Breaking changes MUST be documented in the changelog
- Skip `chore` commits (gitignore, gitkeep, symlinks, CI config, deps bumps)

CHECKLIST
=========

- Changes grouped by date (newest first)
- Changes grouped by type (Added, Changed, Fixed, etc.)
- No empty categories
- Dates in ISO 8601
- Entries describe user-facing changes, not commits
