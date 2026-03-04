---
doc_type: policy
lang: en
tags: ['git', 'commits', 'conventional-commits', 'version-control', 'standards']
last_modified: 2026-02-22T12:00:00Z
---

GIT COMMITS AND VERSION CONTROL POLICY
======================================

TL;DR: Conventional Commits required: `<type>(scope)!: subject` (English, imperative, no period, subject ≤ 50 chars).
One commit = one logical change. Keep commits reviewable, and keep each commit in a working state.
Shared branches are linear: merge via PR using rebase or squash (no merge commits). Never force-push shared branches.

CONVENTIONAL COMMITS
====================

Required format
---------------

Header format:

```text
<type>(<scope>)!: <subject>
```

Rules:
- Scope is optional: `<type>: <subject>` is valid.
- `!` is optional and means BREAKING CHANGE only (not "urgent" or "hotfix").
- Use `BREAKING CHANGE:` footer when the change requires consumer action (see BREAKING CHANGES).

Allowed types
-------------

Type     | Use when                                                     | Example
-------- | ------------------------------------------------------------ | ----------------------------------------------
feat     | Add user-visible functionality                                | feat(auth): add OAuth 2.0 login
fix      | Fix a bug                                                     | fix(api): handle null token
perf     | Improve performance without changing behavior                 | perf(db): reduce N+1 queries in orders
refactor | Restructure code without changing behavior                    | refactor(ui): extract form validation hook
docs     | Documentation only                                            | docs: document rollback procedure
test     | Add/fix tests only                                            | test(api): add contract tests for /orders
style    | Formatting only (no behavior change)                          | style: run formatter
build    | Build system/tooling (bundler, compiler, build scripts)       | build: enable incremental builds
ci       | CI/CD config and scripts                                      | ci: cache npm dependencies
chore    | Repo maintenance that doesn't fit above (deps, scripts, etc.)  | chore(deps): bump axios to 1.7.0
revert   | Revert a previous commit                                      | revert: feat(auth): add OAuth 2.0 login

Scope rules
-----------

- Use a short, stable noun for a logical area: `auth`, `api`, `db`, `ui`, `docs`, `deps`, `ci`, `security`.
- Prefer existing scopes. Do not invent new scopes for one-off commits.
- Use lowercase and hyphens only. No spaces.

Subject rules
-------------

- English (required).
- Imperative mood: `add`, `fix`, `remove`, `prevent`, `allow`, `support`.
- No period at the end.
- Maximum 50 characters. Move details to the body.
- Start with lowercase, except proper nouns/acronyms (`JWT`, `OAuth`, `GitHub`).
- Describe the outcome, not the activity.
- Good: `fix(api): return 400 on invalid token`.
- Bad: `fix(api): update token handling`.

Body rules
----------

Use a body when the change is not obvious from the subject.

- Blank line between subject and body (required).
- Wrap lines at ~72 characters where practical (hard stop at 100 for links/paths).
- Explain WHY and any non-obvious WHAT. Do not narrate the code.
- If the commit has multiple steps, use a dash list inside the body.

Footer rules
------------

Footers are for machine-readable metadata.

- Breaking changes: `BREAKING CHANGE: ...` (see BREAKING CHANGES).
- Issue links: `Refs: ABC-123` or `Closes #123` (pick one team-wide convention).
- Pairing: `Co-authored-by: Name <email>` (GitHub recognizes this).

BREAKING CHANGES
================

Definition
----------

A breaking change is any change that requires consumers to update code, configuration, data, or operational procedures.
Severity is not the same as breaking. A critical security fix can be non-breaking.

Required marking
----------------

If a commit is breaking, do BOTH:

- Add `!` in the header.
- Add a `BREAKING CHANGE:` footer that states the required migration/action.

Example:

```text
feat(auth)!: replace API keys with OAuth 2.0

BREAKING CHANGE: API keys are no longer accepted. Use OAuth 2.0 bearer tokens.
```

HOTFIXES AND SECURITY FIXES
===========================

- Use `fix` for hotfixes. They are still fixes.
- Do NOT use `!` unless the hotfix is actually breaking.

Example (non-breaking security fix):

```text
fix(security): patch auth token validation bypass

Refs: CVE-XXXX-YYYY
```

ATOMIC COMMITS
==============

Rules
-----

- One commit = one logical change.
- Each commit should leave the repo in a working state (builds and tests pass).
- Split unrelated changes even if they are small.
- Refactor + docs => 2 commits (`refactor` + `docs`).
- Feature + build/config wiring => usually 2 commits (`feat` + `chore/build`).
- Use `git add -p` to stage only the intended hunks for the commit.
- Dependency updates: keep manifest and lockfile changes together, and avoid mixing deps bumps with code changes.


Separating commits by meaning
----------------------------

Rule: if changes are logically independent and would naturally have different commit types, split them.
Exception: tests that are part of a fix usually stay with the fix.

Wrong (multiple unrelated changes in one commit):

```text
fix: resolve constants issue
```

This kind of commit usually hides multiple changes:
- Bug fix
- Tooling/scripts changes
- Documentation updates

Correct (split by meaning):

```text
fix(config): use correct timeout default
chore(devx): add pre-commit lint hook
docs: document configuration constants
```

Tests with fixes
----------------

Default: commit a bug fix and its tests together for bisectability.
Split only when the test change is large/reusable, or when it would obscure the fix.

HISTORY POLICY FOR SHARED BRANCHES
==================================

No force push
-------------

- Forbidden: `git push --force` to shared branches (`main`, `develop`, release branches).
- Allowed on your own branches when rewriting history, but use `--force-with-lease`, not `--force`.

No merge commits (linear history)
---------------------------------

- Shared branches must be linear.
- Merge via PR using rebase and merge when the branch contains multiple meaningful commits.
- Merge via PR using squash and merge when the branch is a single logical change or contains WIP commits.

Rule of thumb:
- If commits are already clean and atomic, preserve them (rebase and merge).
- If commits are noisy, clean them up first (interactive rebase) or squash at merge time.

LANGUAGE POLICY
===============

English only: commit messages, branch names, tag names, PR titles.


COMMIT EXAMPLES
===============

Short (subject only)
--------------------

```bash
git commit -m "fix(api): return 400 on invalid token"
```

```bash
git commit -m "chore(deps): bump axios to 1.7.0"
```

```bash
git commit -m "docs: add runbook for database restore"
```

Extended (subject + body + footer)
----------------------------------

Prefer using your editor (`git commit`) for multi-line messages.

```text
refactor(api): extract validation layer

Move request validation out of controllers to improve testability.

Refs: ABC-123
```

```text
feat(auth)!: replace API keys with OAuth 2.0

BREAKING CHANGE: API keys are no longer accepted. Use OAuth 2.0 bearer tokens.
```

Revert
------

```text
revert: feat(auth): add OAuth 2.0 login

This reverts commit abc123def.
```

Incorrect examples
------------------

```text
Added new feature                  # No Conventional Commit type
feat: Added new feature            # Not imperative
feat: add OAuth 2.0.               # Period at end
FEAT: add OAuth 2.0                # Uppercase type
update                             # Too vague, no type
fix!: critical security issue      # `!` is for breaking changes, not severity
```

CHECKLIST FOR EACH COMMIT
=========================

- Type is valid and matches the change.
- Scope (if used) is stable and accurate.
- Subject is English, imperative, no period, and concise.
- Commit is atomic and leaves the repo working (build/tests pass).
- Breaking changes are marked with `!` and a `BREAKING CHANGE:` footer.
- No secrets, credentials, or private keys were committed.
- CHANGELOG.md updated (if it exists in the project).
