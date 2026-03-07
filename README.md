# IsaacLab to mjlab Skill Library

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)
[![Type: Skill Library](https://img.shields.io/badge/Type-Skill%20Library-blue)](#)
[![Migration: IsaacLab->mjlab](https://img.shields.io/badge/Migration-IsaacLab--to--mjlab-orange)](#)
[![Tools: Codex | Claude | Gemini | Cursor | OpenCode](https://img.shields.io/badge/Tools-Codex%20%7C%20Claude%20%7C%20Gemini%20%7C%20Cursor%20%7C%20OpenCode-6f42c1)](#)

## Overview

This repository provides a production-oriented skill library for migrating IsaacLab-only projects to mjlab and for authoring new mjlab-native code directly.

The objective is to preserve task behavior during migration while also making it practical to write new mjlab tasks, configs, manager terms, sensors, RL configs, and registration code from local docs/examples.

It now also ships a modular **mjlab API skill pack** distilled from local `mjlab/docs`, so the agent can load only the relevant API domain during migration (envs, managers, sensors, terrains, RL, task registry, etc.).

It works even when the current workspace does not contain a local `mjlab/` checkout: the bundled `references/` pages are the first fallback, and raw `mjlab/docs/...` or `mjlab/src/...` paths are treated as optional lookup targets rather than hard requirements.

## Why this is AI-friendly

- **English-first agent-facing docs** so Codex/Claude/Gemini/Cursor/OpenCode can consume the guidance consistently.
- **Load-on-demand references** so the agent reads only the API slice it needs instead of a monolithic wall of documentation.
- **Compressed migration gotchas** for the highest-value pitfalls that are easy to miss during IsaacLab -> mjlab ports.
- **Authoring recipes** for common requests like “add a reward”, “add a sensor”, “register a task”, or “import a mesh”.
- **Case-study + playbook split** so complex-task guidance stays generic, while tracking remains only a concrete example.

## Refreshed against newer mjlab changes

The skill pack now also calls out several newer/upstream mjlab behaviors that are easy to miss when porting older examples:

- `EventTermCfg(mode="step")` and related event semantics such as `is_global_time` / `min_step_count_between_reset`
- `EntityCfg.sort_actuators` when control ordering must follow joint/tendon/site definition order
- `MetricsTermCfg(func=mdp.mean_action_acc)` in newer upstream velocity-style tasks
- newer RSL-RL model config conventions (`stochastic`, `init_noise_std`, `noise_std_type`)

## Scope

- Migrate IsaacLab projects to **mjlab-native** code paths.
- Write new **mjlab-native** tasks/components/configurations directly.
- Preserve behavior parity for rewards, observations, actions, commands, reset/events, terminations, and curriculum.
- Avoid compatibility layers.
- Do not modify `mujocolab/mjlab` upstream source code.

## Supported Tools

- Codex
- Claude Code
- Gemini CLI
- Cursor
- OpenCode

## Installation

### Interactive Mode (Recommended)

Run the installer without arguments to launch an interactive terminal UI:

```bash
cd isaaclab-to-mjlab
bash scripts/install.sh
```

The TUI lets you:

- **Select target tools** — Codex, Claude Code, Gemini CLI, Cursor, OpenCode (multi-select with `Space`)
- **Choose installation method** — `copy` (production) or `symlink` (development/iterate-in-place)
- **Preview target paths** before confirming

Controls:

| Key | Action |
|-----|--------|
| `↑` / `↓` | Navigate |
| `Space` | Toggle selection / switch method |
| `Enter` | Confirm and install |
| `Q` | Quit without installing |

After pressing `Enter`, the installer runs all selected tools and prints a summary of installed paths.

---

### CLI Mode (Per-tool)

Prefer non-interactive usage? Pass flags directly:

```bash
# Install to a single tool
bash scripts/install.sh --tool claude

# Install to all tools at once
bash scripts/install.sh --tool all

# Use symlink instead of copy (handy when iterating on the rules)
bash scripts/install.sh --tool claude --method symlink

# Specify a project directory for Cursor / OpenCode
bash scripts/install.sh --tool cursor --project /path/to/your/project
```

#### Codex (global)

```bash
bash scripts/install.sh --tool codex
```

Install location:
- `${CODEX_HOME:-~/.codex}/skills/isaaclab-to-mjlab`

#### Claude Code (global)

```bash
bash scripts/install.sh --tool claude
```

Install locations:
- `~/.claude/rules/isaaclab-to-mjlab.md`
- import line added to `~/.claude/CLAUDE.md`

#### Gemini CLI (global)

```bash
bash scripts/install.sh --tool gemini
```

Install locations:
- `~/.gemini/rules/isaaclab-to-mjlab.md`
- import line added to `~/.gemini/GEMINI.md`

#### Cursor (project-scoped)

```bash
bash scripts/install.sh --tool cursor --project /path/to/your/project
```

Or, from inside your project:

```bash
bash /path/to/isaaclab-to-mjlab/scripts/install.sh --tool cursor
```

Install location:
- `<project>/.cursor/rules/isaaclab-to-mjlab.mdc`

Notes:
- If `--project` is omitted, installer uses current git repository root; if unavailable, it uses current directory.
- `codex`, `claude`, and `gemini` install to global user paths by default.
- `cursor` remains project-scoped by design.

#### OpenCode

```bash
bash scripts/install.sh --tool opencode
bash scripts/install.sh --tool opencode --project /path/to/your/project
```

Install locations:
- global: `~/.config/opencode/skills/isaaclab-to-mjlab/`
- project: `<project>/.opencode/skills/isaaclab-to-mjlab/`
- installed skill payload mirrors the repository layout, such as `SKILL.md`, `README.md`, `references/`, `shared/`, and `scripts/`

Notes:
- If `--project` is omitted, OpenCode installs globally to `~/.config/opencode/skills/isaaclab-to-mjlab/`.
- If `--project` is provided, OpenCode installs into that project under `.opencode/skills/isaaclab-to-mjlab/`.
- The installer prints an install summary with the exact destination path for each selected tool.

## Repository Structure

```text
isaaclab-to-mjlab/
├── SKILL.md
├── agents/openai.yaml
├── references/
│   ├── mjlab-api-pack.md
│   ├── mjlab-api-index.md
│   ├── mjlab-authoring-workflow.md
│   ├── mjlab-authoring-recipes.md
│   ├── mjlab-api-*.md
│   └── mjlab-mdp-builtins.md
├── shared/isaaclab-to-mjlab-rules.md
├── adapters/cursor/isaaclab-to-mjlab.mdc
└── scripts/
    ├── install.sh
    └── package.sh
```

## Release Packaging

```bash
bash scripts/package.sh v0.1.0
```

Generated files:
- `dist/isaaclab-to-mjlab-v0.1.0.tar.gz`
- `dist/isaaclab-to-mjlab-v0.1.0.zip`

## License

This project is released under the **MIT License**.

See [`LICENSE`](./LICENSE).

## References

- Migration pattern: `mujocolab/anymal_c_velocity`
- mjlab repository: `mujocolab/mjlab`
- IsaacLab repository: `isaac-sim/IsaacLab`
