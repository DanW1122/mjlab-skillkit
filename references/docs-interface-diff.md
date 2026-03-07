# Local Docs Interface Differences (mjlab vs IsaacLab)

This file distills interface differences from local documentation comparisons. It takes precedence over scattered rule-of-thumb migration notes.

## Local Docs Compared in This Round

`mjlab`:

- `mjlab/docs/source/migration_isaac_lab.rst`
- `mjlab/docs/source/environment_config.rst`
- `mjlab/docs/source/scene.rst`
- `mjlab/docs/source/training/rsl_rl.rst`
- `mjlab/docs/source/api/envs.rst`
- `mjlab/docs/source/api/managers.rst`
- `mjlab/docs/source/api/tasks.rst`

`IsaacLab`:

- `IsaacLab/docs/source/tutorials/03_envs/create_manager_rl_env.rst`
- `IsaacLab/docs/source/tutorials/03_envs/register_rl_env_gym.rst`
- `IsaacLab/docs/source/tutorials/02_scene/create_scene.rst`
- `IsaacLab/docs/source/api/lab/isaaclab.envs.rst`
- `IsaacLab/docs/source/api/lab/isaaclab.scene.rst`
- `IsaacLab/docs/source/setup/quickstart.rst`

## Interface Differences at a Glance

## 1) Environment Class Naming

- IsaacLab:
  - Runtime environment class: `ManagerBasedRLEnv`
  - Config class: `ManagerBasedRLEnvCfg`
- mjlab:
  - Runtime environment class: `ManagerBasedRlEnv`
  - Config class: `ManagerBasedRlEnvCfg`

Migration note: rename `RLEnv` -> `RlEnv` everywhere.

## 2) Manager Config Structure (Mandatory)

- IsaacLab: commonly uses nested `@configclass` definitions (for example `RewardsCfg`, `ObservationsCfg`).
- mjlab: injects manager dictionaries directly into `ManagerBasedRlEnvCfg`:
  - `observations: dict[str, ObservationGroupCfg]`
  - `actions: dict[str, ActionTermCfg]`
  - `rewards: dict[str, RewardTermCfg]`
  - `terminations/events/commands/curriculum/metrics` are also dictionaries.

Migration note: all managers must become `dict[str, XxxTermCfg]`; do not keep manager `@configclass` definitions.

## 3) Scene / World Modeling Style

- IsaacLab: clones scenes with `InteractiveSceneCfg` + `prim_path` + `ENV_REGEX_NS`.
- mjlab: uses `SceneCfg` + `entities/sensors`, with no USD `prim_path` system.
  - During scene composition, entities are automatically prefixed with namespaces (for example `robot/base_link`).

Migration note: remove `prim_path` / USD scene-graph thinking completely and switch to MuJoCo scene composition.

## 4) Sensor Interface

- IsaacLab: `isaaclab.sensors.ContactSensorCfg` (bound to the prim hierarchy).
- mjlab: prefer `mjlab.utils.spec_config.ContactSensorCfg` (recommended by the official migration page), though project wrappers such as `mjlab.sensor.ContactSensorCfg` may also appear.

Migration note: contact sensors are typically attached to the robot config (for example `replace(robot_cfg, sensors=(sensor,))`).

## 5) Registration and Task Discovery

- IsaacLab: `gym.register(...)` + `gym.make(...)` is the mainstream tutorial path.
- mjlab: registers tasks with `register_mjlab_task(...)`, where `task_id` binds `env_cfg/play_env_cfg/rl_cfg/runner_cls`.

Migration note: prefer `register_mjlab_task`; do not hardcode tasks by editing upstream `mjlab` source.

## 6) Training Entrypoints and Parameter Overrides

- IsaacLab: commonly uses `isaaclab.sh -p scripts/...`, launched through a gym task id.
- mjlab: commonly uses `uv run train <TaskId>` / `uv run play <TaskId>`.
  - The CLI uses `tyro` for config overrides, with hyphenated flags (for example `--num-envs`).
  - Boolean arguments require explicit `True/False`.

Migration note: move the original training entrypoint into mjlab's train/play command flow.

## 7) Additional Config Semantics (Explicit in mjlab Docs)

Frequently used `ManagerBasedRlEnvCfg` fields that are easy to miss during IsaacLab migration:

- `is_finite_horizon`
- `scale_rewards_by_dt` (rewards are scaled by `step_dt` by default)
- `metrics` manager (dictionary)
- default `events` often include `reset_scene_to_default`

Migration note: make these field semantics explicit during migration; do not migrate only rewards / obs / actions.

## 8) Project Scaffolding Differences

- IsaacLab projects often include `omni.*` / `isaacsim.*` extension and UI scaffolding.
- mjlab migrations do not need that scaffolding by default.

Migration note: files such as `ui_extension_example.py` and `config/extension.toml` are usually not kept unless the user explicitly asks for them.

## 9) Fallback and Comment Policy (Migration Discipline)

- If the source project has no fallback branch, do not add one.
- Fallback behavior must match the source logic one-for-one; do not add extra "safety code".
- Keep original comments and TODOs; only make minimal terminology substitutions for mjlab.
- Explicitly reject compatibility layers: do not add compat / adapter / shim bridge code.
- Do not add `raise` / `assert` statements that do not exist in the source project.

## 10) "mjlab-native + Equivalence" Principle

- The migration target is a native mjlab implementation, not preserving IsaacLab code shape.
- Internal implementation changes caused by interface differences are allowed.
- The success criterion is not "does the code look the same", but "are the final function and behavior equivalent".
- If implementation differs, record the differences and the equivalence rationale in the migration notes.

## Recommended Migration Procedure

1. First use this file as an interface-level checklist, then start rewriting code.
2. After each manager rewrite, immediately verify that the final injected type is a dictionary.
3. After each scene / sensor rewrite, immediately check for leftover `prim_path` / `ENV_REGEX_NS` / `omni.` references.
4. After completion, run the full verification in `references/checklist.md`.
