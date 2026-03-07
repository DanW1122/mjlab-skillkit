# Migration Rules

## Official Baseline

- Official migration pattern repository: `https://github.com/mujocolab/anymal_c_velocity`
- mjlab API reference repository: `https://github.com/mujocolab/mjlab`
- IsaacLab source-behavior reference repository: `https://github.com/isaac-sim/IsaacLab`
- Official migration notes (continuously updated): `references/official-migrating-from-isaaclab.md`
- Compressed high-value gotchas: `references/migration-gotchas.md`
- Local docs interface-diff digest: `references/docs-interface-diff.md`
- mjlab API migration pack: `references/mjlab-api-pack.md`
- mjlab API domain index: `references/mjlab-api-index.md`
- If this is not a migration but direct mjlab authoring, read instead: `references/mjlab-authoring-workflow.md`
- If STL / OBJ / other mesh asset import is involved, additionally read: `references/mjlab-mesh-import-guidelines.md`
- If you are migrating a multi-variant / command-heavy / play-eval-sensitive task, read first: `references/complex-task-migration-playbook.md`
- If you are migrating a motion-tracking / whole-body-tracking task, also read: `references/tracking-case-study.md`
- If you are migrating a tracking / imitation / whole-body-control task, additionally inspect the target task family’s `config/*/__init__.py` and related `tests/`, and treat them as behavior contracts.

## Documentation Source-of-Truth Rules

- Prefer local documentation in the target repository first (for example `mjlab/docs` and `IsaacLab/docs`).
- In this skill, interface mappings follow conclusions derived from local docs first; online docs are only for filling gaps.
- If local docs conflict with online docs, default to the local docs version first and record the difference in the migration notes.
- Before migrating, complete at least one interface-level comparison using `references/docs-interface-diff.md`.

## Official Migration Notes Status

- The official migration notes are still work in progress.
- If you encounter an uncovered pattern or edge case, prefer supplementing via:
  - Issues: `https://github.com/mujocolab/mjlab/issues`
  - Discussions: `https://github.com/mujocolab/mjlab/discussions`

## Directory Layout Selection Rules (must decide first)

- Mode A: `preserve-layout` (keep the original project structure)
  - Keep the original repository layout and module paths.
  - Focus the migration on API/config semantics, without forcing a file-tree reorganization.
- Mode B: `mjlab-layout` (convert directly into mjlab style)
  - Align with the directory organization and registration style of `anymal_c_velocity`.
  - Recommended for new task packages and long-term maintenance consistency.
- If the user has not stated a choice, you must ask before starting the migration.

## Scope

- Before editing files, confirm the editable scope based on the user request or repository rules.
- Treat IsaacLab source code as the behavioral baseline.
- By default, only edit the target mjlab implementation files unless the user explicitly asks to modify other directories.
- Under any repository layout, do not modify `mujocolab/mjlab` source code (including submodule/vendor/mirror directories).

## Handling IsaacLab Project-Specific Files

- By default, do not migrate IsaacLab/Omniverse extension scaffolding files.
- In your InstinctLab, typical examples include:
  - `source/instinctlab/instinctlab/ui_extension_example.py`
  - `source/instinctlab/config/extension.toml`
  - `source/instinctlab/setup.py` (if it is only used for extension metadata packaging)
  - `.vscode/tools/setup_vscode.py` (Isaac Sim development-environment helper)
- Only if the user explicitly requires preserving Isaac Sim extension capability should you separately evaluate whether to keep them; otherwise, treat them all as “not migration targets”.

## Core Goal

Migrate IsaacLab tasks/environments to mjlab while keeping the following behaviors fully equivalent:

- rewards
- observations
- actions
- commands
- terminations
- reset/events
- curriculum

Migration priority:

1. Final functionality/behavior equivalence (highest priority)
2. mjlab-native implementation (must become truly mjlab-native)
3. Stay as close as possible to the source code structure when that does not conflict with the first two goals

## Hard Constraints

- Preserve source comments and TODO semantics; do not delete original comments.
- Comments may receive only minimal necessary mjlab wording updates (for example `ManagerBasedRLEnv` -> `ManagerBasedRlEnv`, `prim_path` -> `entities`), without changing the original meaning.
- By default, keep function boundaries and call order aligned with the source implementation.
- Do not omit original logic steps, function boundaries, call order, or config items.
- Do not introduce unsupported helper abstractions (extra inheritance, wrapper layers, merging/splitting functions, major reordering).
- If mjlab interface differences prevent literal one-to-one transport, minimal implementation differences are allowed, but behavior must stay equivalent and the final code must be mjlab-native.
- Prioritize behavioral/semantic equivalence over literal source control-flow shape; when exact transport is impossible, choose the smallest mjlab-native implementation that preserves the same task behavior.
- Do not perform structural rewrites purely for style reasons.
- Explicitly reject compatibility layers: do not add compatibility layers, adapter shims, or bridge wrappers.
- Manager configuration must use the official dict style (`dict[str, XxxTermCfg]`); do not keep nested manager `@configclass` patterns.
- Fallback/guard logic must stay aligned with source behavior: keep it if the source has it; do not add it if the source does not.
- If the source project has no fallback logic, do not add any fallback branches (including broad `try/except`, `hasattr` branches, or silent degradation to defaults), unless mjlab/target API requirements force a minimal guard for correctness.
- Do not add `raise`/`assert` statements that do not exist in the source project, unless mjlab/target API requirements force a minimal check for correctness; otherwise only preserve exception/assertion behavior that already exists in the migration source.
- Do not modify upstream mjlab source; migrated code must live in your target project and depend on mjlab as a dependency.
- After migration, clean up all Isaac/IsaacLab interface residue.
- By default, do not keep Isaac Sim UI extension-related entry points or dependencies (`omni.*` / `isaacsim.*` project scaffolding layers).
- Do not copy entire source files verbatim; adapt them to mjlab interfaces and the target project structure.
- Preserve source-project-specific semantic names (for example `hack_generator`) unless mjlab explicitly requires a field mapping.

## Officially Recommended Migration Organization (aligned with anymal_c_velocity)

- Use the “standalone task project + dependency on `mjlab`” model instead of editing source directly inside the `mjlab` repository.
- Declare the `mjlab` dependency in the project’s `pyproject.toml`.
- Expose the task package through `[project.entry-points."mjlab.tasks"]` so mjlab can auto-discover tasks.
- Register task variants in the task package `__init__.py` via `register_mjlab_task(...)`.
- This organization corresponds to `mjlab-layout` by default; `preserve-layout` may borrow the API expression style without copying the directory tree.

## Manager Configuration Rules

- Manager configuration must return `dict[str, XxxTermCfg]`.
- Prefer factory functions to construct manager dicts, so variants can reuse and override them.
- If the target project already follows dict-style managers, keep managers fully dict-based.
- Using `@dataclass` for the main EnvCfg and SceneCfg is allowed, but manager fields must be dicts.
- Manager fields must be initialized with `field(default_factory=make_xxx)`; do not keep class-style manager config.
- Do not introduce bridge conversion tools just to preserve IsaacLab class-config style.
- Explicitly banned bridge tools: `manager_terms_to_dict`, `AttrDict`, `observation_terms_from_class`.
- All managers (`rewards/observations/actions/commands/terminations/events/curriculum`) follow the same rule set.

## Migration Style

- Use a one-to-one migration rhythm.
- Keep directory structure and function order as close as possible to the source task.
- Prefer existing mjlab-native expression patterns already present in the target codebase.
- When interface differences change the implementation shape, prefer the native mjlab official API style instead of keeping an IsaacLab semantic shell.
- Limit changes to: imports, API field names, config expression style, and registration wiring.

## Additional Rules for Complex Task Families

- For complex task families (especially tracking / imitation / whole-body-control), first read on the target side:
  - the task registration files (usually the task package `__init__.py`)
  - test files for the same task family
- These files are not “supplementary material”; they are direct constraints on behavioral equivalence in the target repository.
- Before migrating, first write a **variant matrix** that at minimum lists:
  - base training variant
  - no-state-estimation variant
  - play variant
  - low-freq / other special variants
- Do not assume “one source variant = one target task id”:
  - in mjlab, some source variants may become independent `task_id`s
  - others may collapse into `play_env_cfg=...` or factory parameters (for example `play=True`)
- If the target side is missing a source variant, you must state it explicitly as one of:
  - intentionally not migrated
  - not yet migrated
  - still needs migration
- For tracking tasks, prioritize verifying these invariants:
  - whether a `motion` command exists
  - whether the key contact/self-collision sensor exists
  - whether the no-state-estimation variant truly removes the correct actor observation terms
  - whether play mode disables the relevant randomization and switches to the correct sampling mode
  - whether key hyperparameters such as action scale / decimation / PPO gamma-lam still match
