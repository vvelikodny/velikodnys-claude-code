---
doc_type: guide
lang: en
tags: ['testing', 'rust', 'cargo', 'make', 'integration']
paths:
  - '**/*.rs'
last_modified: 2026-02-11T20:48:47Z
---

RUST TESTING RULES
==================
TL;DR: Run tests through make targets for stable, repeatable results.
Tier 0 is mandatory before commits, Tier 1 daily, Tier 2 slow or environment-dependent.
Integration tests are grouped into per-domain test binaries and must run serially with `--test-threads=1`.
Every new integration test must be assigned to a group and wired into the Makefile and this registry.

Core principles
---------------
- Prefer fast feedback loops: Tier 0 should stay small enough to run before every commit.
- Prefer determinism over cleverness: no real home directory, no real network, no reliance on timing.
- Prefer reproducibility: every failure should have a single command to rerun it.

Test layout and terminology
---------------------------
Unit-style tests
................
- Our "unit tests" live under `tests/` and are compiled by Cargo as an integration test binary.
- Location: `tests/unit.rs` (aggregator) and `tests/unit/**` (modules included by the aggregator).
- Characteristics: fast, isolated, should not require feature flags or external environment.

Integration tests
.................
- Scenario-level tests grouped by domain into separate Cargo test binaries.
- Location: `tests/integration_<group>.rs` (group binaries) and `tests/integration/**` (scenario modules).
- Characteristics: exercise real workflows, may be slower, some groups require feature flags.

Other targets
.............
- Examples: `examples/**` (demos; not part of normal test tiers).
- Benchmarks: `benches/**` (performance measurement; not correctness tests).

Feature flags
-------------
- Some integration groups are gated behind Cargo features (for example `azure-speech`, `azure-test-support`).
- The Makefile is the source of truth for which features each group/tier enables.
- Production builds must not include test-only feature flags such as `azure-test-support`.

How to run tests
----------------
Fast UI scrollbar check:
```bash
make test-ui-scrollbar
```

All unit-style tests:
```bash
make test-unit
```

Tier 0 (fast, mandatory before commits):
```bash
make test-tier0
```

Tier 1 (daily run):
```bash
make test-tier1
```

Tier 2 (slow or environment-dependent):
```bash
make test-tier2
```

All integration groups (serial):
```bash
make test-integration
```

Single group example:
```bash
make test-hotkeys
```

Full project tests (excluding benches):
```bash
make test-all
```

Lint:
```bash
make lint
```

Strict lint (local, fails on warnings):
```bash
cargo clippy --all-targets -- -D warnings
```

Tier system
-----------
- Tier 0: fast and mandatory before commits. Keep it deterministic and under a few minutes.
- Tier 1: daily run over core domains. Should still be deterministic and run on CI.
- Tier 2: slow, manual, or environment-dependent. Do not add flaky tests to Tier 0/1.

Serial execution rules for integration tests
--------------------------------------------
Integration tests must not run in parallel (neither across groups nor within a group).

Do not do this:
```bash
cargo test --tests
```

Do not do this:
```bash
cargo test --test integration_hotkeys
```

Do this instead:
```bash
make test-integration
```

Manual run fallback (single group only):
```bash
cargo test --test integration_hotkeys -- --test-threads=1
```

Why `--test-threads=1`:
- Some scenarios still share process-wide resources (for example log directories).
- Running tests in parallel produces non-deterministic failures.

Integration test groups
-----------------------
Group name conventions:
- Group name is kebab-case (example: `ai-openrouter`).
- Group binary file is `tests/integration_<group>.rs`.
- Make target is `test-<group>`.
- Scenario modules live in `tests/integration/**` and are included by the group binary.

Core groups (no feature flags)
..............................
- hotkeys: tests/integration/hotkeys_test.rs
- logging: tests/integration/logging_test.rs
- config-core: tests/integration/config_behavior_test.rs, tests/integration/hot_reload_invalid_hex_test.rs,
  tests/integration/missing_config_exit.rs, tests/integration/config_invalid_exit.rs
- startup: tests/integration/first_run_test.rs
- cli: tests/integration/cli_args_test.rs, tests/integration/quit_test.rs,
  tests/integration/us2_cli_override_test.rs, tests/integration/command_removal_test.rs
- data-loader: tests/integration/data_loader_test.rs
- elapsed-time: tests/integration/elapsed_time_smoke_test.rs, tests/integration/elapsed_time_ui_test.rs
- ui-core: tests/integration/ui_render_test.rs, tests/integration/footer_test.rs,
  tests/integration/navigation_test.rs, tests/integration/solutions_popup_test.rs,
  tests/integration/ui_scrollbar_render.rs, tests/integration/ui_test.rs
- ui-screenshot: tests/integration/screenshot_apply_test.rs, tests/integration/screenshot_flow_test.rs
- ui-vision: tests/integration/vision_token_tracking_test.rs
- ai-client-config: tests/integration/ai_client_config_test.rs
- ai-anthropic: tests/integration/anthropic_test.rs
- ai-gemini: tests/integration/gemini_test.rs
- ai-openrouter: tests/integration/openrouter_config_error_test.rs,
  tests/integration/openrouter_fallback_test.rs, tests/integration/openrouter_rate_limit_test.rs,
  tests/integration/openrouter_server_error_test.rs, tests/integration/openrouter_usage_test.rs
- ai-dispatch: tests/integration/ai_dispatch_test.rs
- adaptivity: tests/integration/adaptivity_test.rs
- backward-compat: tests/integration/backward_compat_test.rs
- dual-track: tests/integration/dual_track_e2e_test.rs
- history-player: tests/integration/history_player_test.rs

Groups requiring feature `azure-speech`
......................................
- config-hot-reload: tests/integration/hot_reload_test.rs
- persistence: tests/integration/persistence_test.rs, tests/integration/elapsed_time_persistence_test.rs
- edge-cases: tests/integration/edge_cases_test.rs
- crash-recovery: tests/integration/crash_recovery_test.rs, tests/integration/partner_file_eof_test.rs
- cost-optimization: tests/integration/cost_optimization_test.rs
- azure-core: tests/integration/azure_integration_test.rs, tests/integration/commands_test.rs,
  tests/integration/start_unavailable_device_test.rs, tests/integration/smoke_test.rs
- azure-dual: tests/integration/dual_manager_race_test.rs, tests/integration/dual_pause_test.rs,
  tests/integration/dual_recognition_test.rs
- azure-poison: tests/integration/azure_poison_mutex_test.rs
- azure-perf: tests/integration/perf_latency_test.rs, tests/integration/performance_test.rs
- azure-wav: tests/integration/azure_wav_recognition_test.rs
- recognizer: tests/integration/recognizer_test.rs, tests/integration/named_device_test.rs

Groups requiring feature `azure-test-support`
.............................................
- ai-cost-estimate: tests/integration/ai_cost_estimate_test.rs
- ai-suggest: tests/integration/suggest_flow_test.rs, tests/integration/preserve_suggestion_error_test.rs
- success-criteria: tests/integration/success_criteria_test.rs

Rules for adding new integration tests
--------------------------------------
01. Decide whether the test is unit-style or integration. Prefer unit-style when it still exercises the intended logic.
02. Pick an existing group by domain. If the group does not exist, create one.
03. Add the new scenario file under `tests/integration/` and name it `*_test.rs`.
04. Include the new module in `tests/integration_<group>.rs` (follow the existing module pattern).
05. Ensure a `test-<group>` target exists in the Makefile.
06. Ensure the target runs the group with `--test-threads=1`.
07. If the group is feature-gated, ensure the target passes the required `--features`.
08. Add the group to the correct tier target (tier0/1/2).
09. Update the group registry in this document and note required feature flags.
10. Never leave an integration test without a group and a Makefile target.

Parallel-safety checklist
-------------------------
- Use a unique temp directory per test case (never write to ~/.randt).
- Avoid shared log directories and other process-global state (env vars, fixed filenames, global singletons).
- Do not depend on execution order, wall-clock timing, or real network access.

Group update checklist
----------------------
- New file in `tests/integration/**` is included in the correct `tests/integration_<group>.rs`.
- Makefile has a `test-<group>` target that runs the group binary.
- Tier targets are updated (tier0/1/2).
- This document reflects group membership and feature flags.

Debugging failures
------------------
Rerun a whole group with backtraces:
```bash
RUST_BACKTRACE=1 make test-hotkeys
```

Rerun a single test case (manual cargo fallback):
```bash
RUST_BACKTRACE=1 cargo test --test integration_hotkeys graceful_shutdown_logs_in_order -- --nocapture --test-threads=1
```

Tips:
- Add `-- --nocapture` to see stdout/stderr.
- If a test mutates environment variables, run it alone and keep `--test-threads=1`.

What tests must not touch
-------------------------
- Your real ~/.randt directory.
- Real credentials or accounts.
- Unmocked network calls to real providers (HTTP is mocked for Anthropic, Gemini, and OpenRouter).

FAQ
---
Q: Why does a test not build without Azure features?
A: Some groups are gated behind `azure-speech`. Use the Makefile targets; they pass the right `--features`.

Q: Why does `make test-all` not run benchmarks?
A: Benchmarks are not correctness tests and are intentionally excluded from the normal test flow.

Q: How do I run everything?
A: Use `make test-all`.

Q: Why do integration tests fail when run directly with `cargo test`?
A: Cargo can run multiple tests in parallel by default; our integration suite still has shared resources.
   Always run integration tests via make, or use `--test-threads=1` for a single group.
