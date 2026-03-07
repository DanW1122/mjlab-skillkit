# IsaacLab to mjlab Skill Library

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)
[![Type: Skill Library](https://img.shields.io/badge/Type-Skill%20Library-blue)](#)
[![Migration: IsaacLab->mjlab](https://img.shields.io/badge/Migration-IsaacLab--to--mjlab-orange)](#)
[![Tools: Codex | Claude | Gemini | Cursor | OpenCode](https://img.shields.io/badge/Tools-Codex%20%7C%20Claude%20%7C%20Gemini%20%7C%20Cursor%20%7C%20OpenCode-6f42c1)](#)

## Overview

This repository provides a production-oriented skill library for migrating IsaacLab-only projects to mjlab.

The objective is to preserve task behavior while converting implementation details to native mjlab patterns.

## Scope

- Migrate IsaacLab projects to **mjlab-native** code paths.
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
