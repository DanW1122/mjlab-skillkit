# isaaclab-to-mjlab

A migration skill that helps convert IsaacLab-only projects to mjlab while keeping behavior equivalent.

## What this project does

This project packages migration rules and install adapters for four tools:

- Codex
- Claude Code
- Gemini CLI
- Cursor

Core goal:

- Migrate IsaacLab task projects to mjlab-native implementations.
- Keep rewards/observations/actions/commands/reset/terminations/curriculum behavior equivalent.
- Avoid compatibility layers and avoid modifying mjlab upstream source code.

## Install by tool (no one-shot global install)

### Codex

Local clone:

```bash
cd isaaclab-to-mjlab
bash scripts/install.sh --tool codex
```

Install path:

- `${CODEX_HOME:-~/.codex}/skills/isaaclab-to-mjlab`

### Claude Code

Local clone:

```bash
cd isaaclab-to-mjlab
bash scripts/install.sh --tool claude
```

Install paths:

- `~/.claude/rules/isaaclab-to-mjlab.md`
- import added to `~/.claude/CLAUDE.md`

### Gemini CLI

Local clone:

```bash
cd isaaclab-to-mjlab
bash scripts/install.sh --tool gemini
```

Install paths:

- `~/.gemini/rules/isaaclab-to-mjlab.md`
- import added to `~/.gemini/GEMINI.md`

### Cursor

Local clone:

```bash
cd isaaclab-to-mjlab
bash scripts/install.sh --tool cursor --project /path/to/your/project
```

or from a project directory:

```bash
bash /path/to/isaaclab-to-mjlab/scripts/install.sh --tool cursor
```

Install path:

- `<project>/.cursor/rules/isaaclab-to-mjlab.mdc`

If `--project` is omitted for Cursor, installer uses current git repo root (fallback: current directory).

Global-by-default behavior:

- `codex`, `claude`, `gemini`: installed to global user paths by default.
- `cursor`: installed per project (`.cursor/rules`), so it remains project-scoped.

## Package release assets

```bash
bash scripts/package.sh v0.1.0
```

This creates:

- `dist/isaaclab-to-mjlab-v0.1.0.tar.gz`
- `dist/isaaclab-to-mjlab-v0.1.0.zip`

## Notes

- Installer is idempotent (safe to run repeatedly).
- Main migration constraints are in `SKILL.md` and `shared/isaaclab-to-mjlab-rules.md`.
