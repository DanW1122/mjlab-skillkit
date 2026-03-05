---
name: isaaclab-to-mjlab
description: Migrate IsaacLab-only projects to mjlab with strict behavior equivalence. Use mujocolab/anymal_c_velocity as the primary migration pattern, reference isaac-sim/IsaacLab and mujocolab/mjlab docs, do not modify mjlab source code, and remove IsaacLab API residue without adding compatibility layers.
---

# IsaacLab to mjlab Migration

## Official Repositories

- Migration pattern (official): `https://github.com/mujocolab/anymal_c_velocity`
- mjlab repository (read-only reference): `https://github.com/mujocolab/mjlab`
- IsaacLab repository (source behavior reference): `https://github.com/isaac-sim/IsaacLab`

## Documentation Priority

- Use local `docs/` in the target workspace as source of truth first (for example `mjlab/docs` and `IsaacLab/docs`).
- Read `references/docs-interface-diff.md` before implementation and follow the listed API differences.
- Read `references/mjlab-api-pack.md` and prefer existing mjlab APIs over any custom wrappers.
- Fall back to online docs only when local docs are missing or incomplete.

## Layout Mode (must choose before migration)

- `preserve-layout`:
  - Keep original repository structure and module paths.
  - Only migrate API/config semantics to mjlab.
- `mjlab-layout`:
  - Reorganize into `anymal_c_velocity` style task package layout (for example `src/<task_pkg>/...`).
  - Use `mjlab.tasks` entry points and `register_mjlab_task(...)` for registration.
- If user does not specify, ask first:
  - `Do you want to keep the original project layout, or convert directly to mjlab layout?`

## Workflow

1. Confirm migration scope, source path, and target path before editing.
2. Confirm layout mode: `preserve-layout` or `mjlab-layout`.
3. Read `references/migration-rules.md` and enforce all hard constraints.
4. Read `references/docs-interface-diff.md` for API differences from local docs.
5. Read `references/mjlab-api-pack.md` and lock target APIs.
6. Read `references/official-migrating-from-isaaclab.md` for boundary notes.
7. For `mjlab-layout`, align project packaging/registration with `anymal_c_velocity`.
8. Read `references/mapping.md` while replacing imports/fields/term APIs.
9. Read `references/patterns.md` while implementing EnvCfg/SceneCfg/manager structures.
10. Reuse native mjlab patterns from existing tasks in target repo and mjlab repo.
11. Run `references/checklist.md` validation before completion.

## Hard Constraints

- Preserve behavior equivalence for rewards, observations, actions, commands, reset/events, terminations, and curriculum.
- Final implementation must be mjlab-native, not IsaacLab-style compatibility code.
- Keep function boundaries, call order, and config semantics aligned with source unless mjlab API differences require minimal internal changes.
- Do not drop source logic steps, config items, or execution order.
- Do not add arbitrary abstractions (extra inheritance/wrappers/major restructuring).
- Do not modify `mujocolab/mjlab` source code.
- Manager configuration must be dict-based (`dict[str, XxxTermCfg]`), not manager `@configclass`.
- Explicitly ban bridge helpers:
  - `manager_terms_to_dict`
  - `AttrDict`
  - `observation_terms_from_class`
- Remove Isaac/IsaacLab API residue (imports, symbols, stale comments, legacy fields).
- Keep source-specific semantic names (for example `hack_generator`) unless forced field mapping is required.
- Do not keep IsaacLab/Omniverse extension scaffolding by default (`ui_extension_example.py`, `config/extension.toml`, `omni.*` extension files).
- No compatibility layer / adapter shim / transition wrappers.
- Do not add new `raise` or `assert` if the source task has none.
- Do not add fallback logic if the source task has none (no broad `try/except`, no `hasattr`-style fallback branches, no silent degradations).
- Keep original comments/TODOs. If wording must change, only do minimal mjlab terminology updates while preserving meaning.

## Execution Notes

- Prefer one-to-one migration, not refactor-oriented rewrite.
- Keep source comments/TODO semantics intact.
- For API mismatch, use minimal mjlab-native adaptation instead of bridge code.
- For `mjlab-layout`, prefer `anymal_c_velocity` packaging pattern: standalone task package + `mjlab.tasks` entry point + `register_mjlab_task`.
- For `preserve-layout`, keep directory structure and only migrate API/config/registration wiring.
- Managers should be generated via dict factory functions and initialized with `field(default_factory=make_xxx)` when dataclass config style is used.
- If inherited config chains are not supported in target style, flatten them via explicit dict merge/override.
- Follow target project registration conventions (prefer project-level registrar; use `gym.register` only when target project explicitly requires it).
