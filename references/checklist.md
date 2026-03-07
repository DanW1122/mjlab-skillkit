# Migration Checklist

## Before Editing

- Confirm the source task path and target path.
- Confirm the directory layout mode chosen by the user: `preserve-layout` or `mjlab-layout`.
- Confirm the migration scope and protected/non-editable areas according to repository rules.
- Confirm that the `mujocolab/mjlab` source tree is read-only reference material and outside the current edit scope.
- Read `references/docs-interface-diff.md` and confirm which interface differences this migration must cover.
- Read `references/mjlab-api-pack.md` and confirm the modules you will use are in the official mjlab API list.
- Read `references/official-migrating-from-isaaclab.md` and confirm the current case does not violate its boundary notes.
- Scan `references/migration-gotchas.md` first to avoid basic pitfalls.
- If STL / OBJ / other mesh assets are involved: read `references/mjlab-mesh-import-guidelines.md`.
- If this is a multi-variant / command-heavy / play-eval-sensitive task: read `references/complex-task-migration-playbook.md`.
- If this is a tracking / whole-body-tracking task: read `references/tracking-case-study.md`.
- If this is a complex task: list the source variants / target variants matrix before touching code.
- Make explicit that this migration uses official manager configuration style: `dict[str, XxxTermCfg]` (do not keep manager `@configclass`).
- Decide explicitly whether IsaacLab project-specific scaffolding is preserved; the default answer should be “no”.
- Confirm the target module style (dataclass + dict-manager, or the project’s equivalent convention).
- Make explicit that the migration target is “mjlab-native implementation + behavioral equivalence”, not “line-by-line code shape equivalence”.

## During Migration

- Preserve one-to-one function mapping and call order.
- Preserve comments and TODO semantics.
- If the mode is `mjlab-layout`: align with `anymal_c_velocity` organization (standalone task package + `mjlab.tasks` entry point + `register_mjlab_task`).
- If the mode is `preserve-layout`: keep the original directory tree and only migrate API/config semantics plus registration wiring.
- Compare against similar `mjlab/**` implementations and reuse existing expression patterns.
- If the source task has multiple variants (for example no-state-estimation / low-freq / play variants), verify them one by one; do not migrate only the main variant and silently ignore the rest.
- If the target repository already has tests for the same task family, copy their assertions into a migration contract and keep checking against it throughout the migration.
- If interface differences prevent literal one-to-one transport, internal implementation adjustments are allowed, but the result must converge to native mjlab APIs.
- Convert Isaac Lab manager `@configclass` structures term by term into `dict[str, XxxTermCfg]`.
- Cover all managers: `rewards/observations/actions/commands/terminations/events/curriculum`.
- If the target style requires dict-based managers, rewrite manager definitions as factory functions that return dicts.
- If the path uses dataclass EnvCfg/SceneCfg, confirm all manager fields are initialized with `field(default_factory=make_xxx)`.
- Confirm none of these bridge tools are used: `manager_terms_to_dict`, `AttrDict`, `observation_terms_from_class`.
- Replace IsaacLab-specific interfaces with mjlab-equivalent fields/imports (including `RlEnv` naming details).
- Replace the `InteractiveSceneCfg` + `prim_path` mindset with `SceneCfg` + `entities/sensors`.
- Prefer migrating contact sensors to `mjlab.utils.spec_config.ContactSensorCfg` (or the project’s equivalent wrapper).
- If mesh assets participate in collision, explicitly separate visual mesh from collision representation; for non-convex collision geometry, prefer convex decomposition or multiple primitive / convex geoms.
- If there is a fixed-base entity, confirm the reset event actually places it at the corresponding `scene.env_origins` location instead of leaving it at the world origin.
- If the source contains cross-entity assembly (tendon / rope / worldbody-level structure), evaluate whether it should move to `SceneCfg.spec_fn`; do not force it into a single entity cfg.
- If action slicing or actuator semantics depend on `model.ctrl` order, explicitly verify whether default actuator declaration order or `EntityCfg.sort_actuators=True` matches the source behavior.
- For contact-sensitive tasks, confirm whether `ContactSensorCfg.history_length` should align with `decimation`.
- For tracking tasks, explicitly verify that `anchor_body_name`, `body_names`, `pose_range`, `velocity_range`, and `joint_position_range` were migrated completely.
- Check whether `scale_rewards_by_dt`, `is_finite_horizon`, `metrics`, and similar mjlab EnvCfg semantics must be set/preserved explicitly.
- Do not migrate Isaac Sim UI extension code (for example `omni.ext` / `omni.ui` example entry points).
- Keep rewards/observations/actions/commands/reset/termination/curriculum behavior equivalent.
- If exact source control flow cannot be preserved because of mjlab API differences, confirm the chosen implementation is the smallest mjlab-native variant that preserves the same behavior.
- Keep fallback logic exactly aligned with the source implementation (do not add more, do not lose existing behavior).
- If the source project has no fallback logic, confirm there is no newly added broad `try/except`, `hasattr` fallback branch, or silent fallback-to-default behavior, unless mjlab/target API semantics explicitly require a minimal guard.
- Confirm there is no newly added compatibility/bridge layer code (compat/adapter/shim/wrapper for the old API).
- If the source project has no `raise`/`assert`, confirm there are no extra exceptions or assertions added unless mjlab/target API semantics explicitly require a minimal check.
- Preserve original comments/TODOs; if comments receive mjlab terminology updates, only replace terms/API names, not meaning.

## Post-Migration Cleanup

- Remove stale imports and unused conversion/compatibility helpers.
- Confirm there is no Isaac/IsaacLab residue left (imports, symbols, comments, old field names).
- Confirm no `mujocolab/mjlab` source files were modified.
- Confirm the final directory organization matches the user-selected mode.
- Confirm manager configuration now follows the target mjlab-native style (without class-wrapper bridges).
- Confirm there is no remaining manager `@configclass`, and all final injected manager values are dicts.
- Confirm IsaacLab extension scaffolding files are not retained (for example `ui_extension_example.py`, `config/extension.toml`).
- Confirm original comments still exist (including TODOs), with only necessary mjlab terminology replacement.
- Confirm the final implementation is a mjlab-native code path that does not depend on an IsaacLab compatibility shell.
- Confirm source-project-specific semantic names are still preserved (for example `hack_generator`) unless forced field remapping required renaming.

## Validation

- Run `python -m py_compile <changed_file>.py` on modified Python files.
- Validate manager field initialization is correct (use `field(default_factory=make_xxx)` where applicable).
- Validate EnvCfg injects manager dict objects, not manager class instances.
- Validate runtime env and config class naming has been replaced correctly: `RLEnv` -> `RlEnv`.
- Validate only MuJoCo-related simulation config remains, with no PhysX/render_interval/physics_material leftovers.
- Validate task registration follows target-project conventions, preferring `register_mjlab_task` + `mjlab.tasks` entry points.
- Validate training/evaluation entry points use the correct task id and env cfg (registered or directly constructed, depending on project organization).
- If the source task has play/no-state-estimation/low-freq or other derived modes, validate whether the target side has equivalent entry points or explicitly record the “not yet migrated” difference.
- If mesh is used for collision, validate that raw non-convex STL/OBJ was not treated as a single collision shape, and validate that contact/reward/sensor logic hits the correct geom names.
- If the source has env-level heterogeneous mesh / geom / asset differences, validate the target did not incorrectly assume “each env can have a different `MjModel`”.
- If the task depends on command initial state right after reset, validate command reset-resample semantics remain equivalent.
- If the target project has `play_env_cfg`, validate play configuration separately; do not validate only the training env.
- If the target repository already has related tests, check their assertions one by one at minimum.
- Run one keyword scan to confirm there are no unnecessary `omni.` / `isaacsim.` dependencies left in the migration target code.
- Run one keyword scan to confirm no new fallback traces were added (such as `hasattr(`, broad `except Exception`, or silent `return default`).
- Run one keyword scan to confirm no new exception/assertion traces (`raise `, `assert `) were added beyond the source project’s scope.

## Behavioral Equivalence Gate

- Reward terms and weights are equivalent.
- Observation terms, order, and corruption behavior are equivalent.
- Action scaling and actuator mapping are equivalent.
- Command sampling and parameter ranges are equivalent.
- Reset/event randomization and termination conditions are equivalent.
- Curriculum progression logic is equivalent.
- Additional validation for tracking tasks: reference-action sampling mode, anchor/body alignment, state-estimation-trimmed variant, and number of registered variants are equivalent.
- Additional validation for tracking / imitation tasks: in play mode, confirm RSI/randomization is disabled and `sampling_mode` is switched to the target-expected value.
- For complex tasks: additionally validate that `play / eval / no-state-estimation / low-freq / robot-specific` variants were not silently dropped.
- If implementation details differ from the source code, provide “difference -> equivalence basis” item by item.

## If You Get Stuck

- First check `mujocolab/mjlab` under `src/mjlab/tasks/`.
- If it is still not covered, report back through official channels:
  - Issues: `https://github.com/mujocolab/mjlab/issues`
  - Discussions: `https://github.com/mujocolab/mjlab/discussions`
