# mjlab API Migration Pack (distilled from local docs)

This file is the **quick entry point**: use it to lock in the major modules first, then read the more detailed domain-specific reference files. That lets you treat the `mjlab` API as a set of skill-style subpackages loaded on demand, instead of reading the entire API surface at once.

It serves both **IsaacLab -> mjlab migration** and **direct mjlab-native authoring**.

## What to read first

1. `references/docs-interface-diff.md`: confirm the interface differences between IsaacLab and mjlab first.
2. `references/mjlab-api-pack.md`: lock in the top-level categories first.
3. `references/mjlab-api-index.md`: choose the precise API domain by problem.
4. Load only the matching `references/mjlab-api-*.md` files plus `references/mjlab-mdp-builtins.md`.
5. If you are writing new mjlab code, also read `references/mjlab-authoring-workflow.md`.

## mjlab API overview

- `mjlab.envs`: environment shell, `ManagerBasedRlEnvCfg`
- `mjlab.scene`: `SceneCfg`, entity / sensor assembly
- `mjlab.managers`: `*TermCfg` for each manager family
- `mjlab.envs.mdp`: common action / observation / reward / event / metric / termination / dr helpers
- `mjlab.sensor`: contact / raycast / camera / builtin sensors
- `mjlab.sim`: `SimulationCfg`, `MujocoCfg`
- `mjlab.entity`: runtime entities and data access
- `mjlab.actuator`: actuator families
- `mjlab.terrains`: flat / generator / curriculum terrain
- `mjlab.rl`: runners, wrappers, PPO configs
- `mjlab.viewer`: native / viser / offscreen
- `mjlab.tasks.registry`: task registration and loading

## Most commonly used APIs during migration (priority order)

### 1) Environment skeleton

- `mjlab.envs.ManagerBasedRlEnv`
- `mjlab.envs.ManagerBasedRlEnvCfg`

### 2) Scene and entity wiring

- `mjlab.scene.SceneCfg`
- `mjlab.terrains.TerrainEntityCfg`
- `mjlab.entity.EntityCfg`

### 3) Manager dictionary configuration

- `mjlab.managers.ObservationGroupCfg`
- `mjlab.managers.ObservationTermCfg`
- `mjlab.managers.ActionTermCfg`
- `mjlab.managers.RewardTermCfg`
- `mjlab.managers.TerminationTermCfg`
- `mjlab.managers.EventTermCfg`
- `mjlab.managers.CommandTermCfg`
- `mjlab.managers.CurriculumTermCfg`
- `mjlab.managers.MetricsTermCfg`

Migration rule: every manager must ultimately be injected into EnvCfg as `dict[str, XxxTermCfg]`, with no manager `@configclass` left behind.

### 4) Common built-in terms / helpers

- `mjlab.envs.mdp.actions.*`
- `mjlab.envs.mdp.observations.*`
- `mjlab.envs.mdp.rewards.*`
- `mjlab.envs.mdp.events.*`
- `mjlab.envs.mdp.metrics.*` (newer upstream mjlab)
- `mjlab.envs.mdp.terminations.*`
- `mjlab.envs.mdp.dr.*`

### 5) Training and registration

- `mjlab.rl.MjlabOnPolicyRunner`
- `mjlab.rl.RslRlVecEnvWrapper`
- `mjlab.rl.RslRlOnPolicyRunnerCfg`
- `mjlab.tasks.registry.register_mjlab_task`

## Which sub-reference to read when

- Environment fields / dataclass structure: `references/mjlab-api-envs.md`
- Scene / entities / `env_origins`: `references/mjlab-api-scene.md`
- Manager term configs: `references/mjlab-api-managers.md`
- Common action / observation / reward / event / metric / termination helpers: `references/mjlab-mdp-builtins.md`
- Contact / raycast / camera: `references/mjlab-api-sensor.md`
- MuJoCo simulation parameters / DR: `references/mjlab-api-sim.md`
- Terrain generators / curriculum: `references/mjlab-api-terrains.md`
- Training runner / wrapper / PPO: `references/mjlab-api-rl.md`
- Task registration / task ids / `load_*`: `references/mjlab-api-tasks.md`

## Usage suggestions

1. Lock the module choice first, then write code. Do not start by adding bridge layers.
2. If IsaacLab API remnants appear, pick the official replacement module from `references/mjlab-api-index.md` first.
3. If code depends on a “custom API” that does not appear in this pack or in local `mjlab/docs`, stop and confirm whether it is actually necessary.
