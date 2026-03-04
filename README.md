# Velikodnyi's Claude Code Plugin

Agent toolkit plugin for Claude Code — bundles coding standards, skills, hooks, and Context7 MCP server.

## What's Included

### CLAUDE.md — Agent Behavior Rules
Loaded every session. Defines communication style, invariants (NEVER change code that wasn't asked to change), and task discipline.

### Rules (via `/setup-rules`)
11 rule files covering coding standards and documentation. Claude Code plugins cannot auto-load `rules/` directories, so use the `/setup-rules` command to copy them into your project's `.claude/rules/`.

| Category | Rules |
|----------|-------|
| **meta** | writing-claude-md |
| **coding** | git-commits, fastapi, kubernetes-yaml, node, yaml, python, python-scripts, rust-testing |
| **docs** | markdown, changelog |

### Skills
- **gcore:changelog** — generates a curated changelog entry from the current PR's commits. Invoke with `/changelog`.

### Hooks
- **UserPromptSubmit** — forces skill evaluation on every prompt so matching skills are called automatically.

### MCP Servers
- **Context7** — library documentation lookup via `@upstash/context7-mcp`.

## Installation

Add the marketplace:

```
/plugin marketplace add vvelikodny/velikodnys-claude-code
```

Install the plugin:

```
/plugin install vvelikodny/velikodnys-claude-code
```

## Setting Up Rules

After installing, run in any project:

```
/setup-rules
```

This copies the rule files into your project's `.claude/rules/` directory where Claude Code can auto-load them.
