# IsaacLab to mjlab Skill Library  
# IsaacLab 到 mjlab 迁移技能库

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)
[![Type: Skill Library](https://img.shields.io/badge/Type-Skill%20Library-blue)](#)
[![Migration: IsaacLab->mjlab](https://img.shields.io/badge/Migration-IsaacLab--to--mjlab-orange)](#)
[![Tools: Codex | Claude | Gemini | Cursor](https://img.shields.io/badge/Tools-Codex%20%7C%20Claude%20%7C%20Gemini%20%7C%20Cursor-6f42c1)](#)

## Overview | 项目简介

**English**  
This repository provides a production-style skill library for migrating IsaacLab-only projects to mjlab.
It is designed to preserve task behavior while converting implementation details to native mjlab patterns.

**中文**  
本仓库提供一个面向工程使用的技能库，用于将仅基于 IsaacLab 的项目迁移到 mjlab。  
目标是在迁移到 mjlab 原生实现的同时，尽可能保持任务行为一致。

## Project Goal | 项目目标

**English**
- Migrate IsaacLab projects to **mjlab-native** code paths.
- Keep behavior equivalent for rewards, observations, actions, commands, reset/events, terminations, and curriculum.
- Avoid compatibility layers and avoid modifying `mujocolab/mjlab` upstream source code.

**中文**
- 将 IsaacLab 项目迁移为 **mjlab 原生**实现路径。  
- 在奖励、观测、动作、命令、重置/事件、终止、课程学习等核心行为上保持等价。  
- 禁止引入兼容层，且不修改 `mujocolab/mjlab` 上游源码。

## Supported Tools | 支持工具

- Codex
- Claude Code
- Gemini CLI
- Cursor

## Install by Tool | 按工具安装

### 1) Codex (global) | 全局安装

```bash
cd isaaclab-to-mjlab
bash scripts/install.sh --tool codex
```

Install path:
- `${CODEX_HOME:-~/.codex}/skills/isaaclab-to-mjlab`

### 2) Claude Code (global) | 全局安装

```bash
cd isaaclab-to-mjlab
bash scripts/install.sh --tool claude
```

Install paths:
- `~/.claude/rules/isaaclab-to-mjlab.md`
- import line added to `~/.claude/CLAUDE.md`

### 3) Gemini CLI (global) | 全局安装

```bash
cd isaaclab-to-mjlab
bash scripts/install.sh --tool gemini
```

Install paths:
- `~/.gemini/rules/isaaclab-to-mjlab.md`
- import line added to `~/.gemini/GEMINI.md`

### 4) Cursor (project-scoped) | 项目级安装

```bash
cd isaaclab-to-mjlab
bash scripts/install.sh --tool cursor --project /path/to/your/project
```

or:

```bash
bash /path/to/isaaclab-to-mjlab/scripts/install.sh --tool cursor
```

Install path:
- `<project>/.cursor/rules/isaaclab-to-mjlab.mdc`

Notes:
- If `--project` is omitted, installer uses current git repo root; if unavailable, it uses current directory.
- `codex`, `claude`, and `gemini` are global by default; `cursor` stays project-scoped.

## Repository Structure | 仓库结构

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

## Packaging | 打包发布

```bash
bash scripts/package.sh v0.1.0
```

Outputs:
- `dist/isaaclab-to-mjlab-v0.1.0.tar.gz`
- `dist/isaaclab-to-mjlab-v0.1.0.zip`

## Open Source License | 开源协议

This project is licensed under the **MIT License**.  
本项目采用 **MIT License** 开源协议。

See: [`LICENSE`](./LICENSE)

## References | 参考

- Migration pattern: `mujocolab/anymal_c_velocity`
- mjlab repository: `mujocolab/mjlab`
- IsaacLab repository: `isaac-sim/IsaacLab`
