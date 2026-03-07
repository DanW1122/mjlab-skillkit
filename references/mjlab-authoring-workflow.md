# mjlab Authoring Workflow

This file is for **writing mjlab-native code directly**, not for IsaacLab migration.

Applicable scenarios:

- creating a new mjlab task
- creating or extending an `EnvCfg`
- creating scene / sensor / terrain configs
- creating reward / observation / event / termination / command / curriculum / metrics terms
- creating an RL config or task registration

## Which docs to read first when authoring

Reference order:

1. target project files you are actually editing
2. local `mjlab/` docs/code if a checkout exists in the workspace
3. bundled skill references such as `references/mjlab-api-*.md`, `references/mjlab-mdp-builtins.md`, and `references/mjlab-authoring-recipes.md`
4. official online docs only if the local checkout and bundled references are both insufficient

Do not load or paste the entire upstream docs tree into context. Use the bundled references as the main working set, then open only the exact upstream page or code file still needed for a missing signature/example.

Base must-reads:

- `mjlab/docs/source/environment_config.rst`
- `mjlab/docs/source/scene.rst`
- `mjlab/docs/source/api/envs.rst`
- `mjlab/docs/source/api/managers.rst`
- `mjlab/docs/source/api/tasks.rst`

Add by feature:

- Actions: `mjlab/docs/source/actions.rst`
- Observations: `mjlab/docs/source/observations.rst`
- Rewards: `mjlab/docs/source/rewards.rst`
- Terminations: `mjlab/docs/source/terminations.rst`
- Commands: `mjlab/docs/source/commands.rst`
- Events / DR: `mjlab/docs/source/events.rst`, `mjlab/docs/source/randomization.rst`
- Curriculum: `mjlab/docs/source/curriculum.rst`
- Metrics: `mjlab/docs/source/metrics.rst`
- Terrain: `mjlab/docs/source/terrain.rst`
- Sensors: `mjlab/docs/source/sensors/index.rst`
- Training: `mjlab/docs/source/training/rsl_rl.rst`
- Mesh / STL / OBJ assets: `references/mjlab-mesh-import-guidelines.md`

If there is no local `mjlab/` checkout, do not stop; use the bundled references first and only ask for an upstream path when exact source signatures/examples are still needed.

## Pick the closest official example first

Do not start from a blank file. Pick the closest existing task first:

- target project task/config already near the requested feature
- then local `mjlab/` example if present
- then bundled skill references if no local checkout is available

- Velocity / locomotion-like tasks: `mjlab/src/mjlab/tasks/velocity/`
- Tracking / reference-motion tasks: `mjlab/src/mjlab/tasks/tracking/`

Look at these files first:

- `mjlab/src/mjlab/tasks/velocity/velocity_env_cfg.py`
- `mjlab/src/mjlab/tasks/velocity/config/g1/env_cfgs.py`
- `mjlab/src/mjlab/tasks/tracking/tracking_env_cfg.py`
- `mjlab/src/mjlab/tasks/tracking/config/g1/env_cfgs.py`

## Recommended build order

### 1) Decide the artifact type first

Be explicit about which of these you are writing:

- base env factory, such as `make_xxx_env_cfg()`
- robot-specific env cfg, such as `unitree_g1_xxx_env_cfg()`
- task-local MDP terms
- RL runner cfg
- task registration

### 2) Write scene and sensors first

Lock in these pieces first:

- `SceneCfg`
- `entities`
- `terrain`
- `sensors`
- `num_envs` / `env_spacing`

If the task depends on raycast / contact / camera sensors, wire them first before connecting them into observations.

If you are importing STL / OBJ / mesh assets:

- decide first whether the asset is visual-only or also participates in collision
- if it collides, do not use a raw non-convex mesh as a single collision geom by default
- prefer:
  - primitive collision geoms
  - or multiple convex parts produced by external convex decomposition
- see `references/mjlab-mesh-import-guidelines.md`

### 3) Write observations next

Prefer reusing:

- `mjlab.envs.mdp.observations.*`
- `mjlab.envs.mdp.builtin_sensor`
- existing observation helpers already defined inside the task

Typical structure:

- `actor`: with noise
- `critic`: with less noise or no noise

Notes:

- `observations` is `dict[str, ObservationGroupCfg]`
- only inside each group do you define `terms: dict[str, ObservationTermCfg]`

### 4) Write actions next

Prefer reusing:

- `JointPositionActionCfg`
- `JointVelocityActionCfg`
- `JointEffortActionCfg`
- `DifferentialIKActionCfg`

Confirm first whether the control target is an actuator, a site, or a tendon. Do not keep an ambiguous old-framework abstraction.

### 5) Write commands next

If the task needs target signals:

- reuse an existing command term from the task whenever possible
- only if reuse is not enough, implement a new `CommandTermCfg` + `CommandTerm`

Note:

- Commands in mjlab are usually class-based, not simple function terms.

### 6) Write events / rewards / terminations next

Common priority:

- `events`: reset, perturbation, domain randomization
- `rewards`: main objective plus regularizers
- `terminations`: `time_out` plus failure conditions

Prefer reusing:

- `mjlab.envs.mdp.events.*`
- `mjlab.envs.mdp.rewards.*`
- `mjlab.envs.mdp.terminations.*`
- `mjlab.envs.mdp.dr.*`

### 7) Add curriculum / metrics / viewer / sim last

- `curriculum`: add it only when training needs staged progression
- `metrics`: record diagnostics only; they do not participate in optimization
- `viewer`: for debugging and play
- `sim`: MuJoCo timestep / solver and related parameters

## Hard authoring rules

- Managers must always be dictionaries, never manager `@configclass` objects.
- Prefer public `mjlab.*` APIs. Do not create your own bridge layer.
- Prefer reusing `mjlab.envs.mdp` helpers and existing helpers in nearby tasks.
- If there is already a closest task, prefer minimal incremental edits based on that example.
- Do not introduce extra abstraction layers early just to make things “generic”.

## Recommended code shape

The most common native mjlab pattern is:

1. `make_xxx_env_cfg()`: provides task-level base configuration
2. `robot_xxx_env_cfg()`: adjusts entities / sensors / rewards for a specific robot
3. `xxx_ppo_runner_cfg()`: training config
4. `register_mjlab_task(...)`: task registration

## Minimal checklist for a new task

- there is a `ManagerBasedRlEnvCfg` that can be returned
- at minimum, `scene` / `actions` / `observations` are complete
- if training is needed:
  - `rewards`
  - `terminations`
  - `rl_cfg`
  - `register_mjlab_task(...)`
- if it can be launched from the CLI:
  - `uv run train <TaskId>`
  - `uv run play <TaskId>`

## Checks before finishing authoring

- all managers are dictionaries
- no old-framework bridge semantics were introduced
- references point to public `mjlab.*` APIs or existing task-local patterns
- the structure stays close to the nearest official example
- at least run a syntax check; if the task is registered, also verify that the registration / loading path is coherent
