# mjlab.envs API Reference

## Sources

- `mjlab/docs/source/api/envs.rst`
- `mjlab/docs/source/environment_config.rst`
- `mjlab/docs/source/migration_isaac_lab.rst`
- `mjlab/src/mjlab/envs/__init__.py`

## Public API

- `mjlab.envs.ManagerBasedRlEnv`
- `mjlab.envs.ManagerBasedRlEnvCfg`
- `mjlab.envs.VecEnvObs`
- `mjlab.envs.VecEnvStepReturn`

## How to use it during migration

- IsaacLab's `ManagerBasedRLEnv` / `ManagerBasedRLEnvCfg` map to mjlab's `ManagerBasedRlEnv` / `ManagerBasedRlEnvCfg`.
- `ManagerBasedRlEnvCfg` is a **single flat dataclass**, not a nested tree of manager `@configclass` objects.
- `scene` is required, and all manager configs live directly on the top level of `EnvCfg`.

## Key fields on `ManagerBasedRlEnvCfg`

- `decimation`: number of physics substeps per policy step
- `sim: SimulationCfg`: entry point for MuJoCo simulation parameters
- `scene: SceneCfg`: assembly entry point for entities, terrain, and sensors
- `episode_length_s`: episode length defined in seconds
- `is_finite_horizon`: distinguishes true termination from time truncation
- `scale_rewards_by_dt`: scales rewards by `step_dt` by default
- `observations / actions / rewards / terminations / events / commands / curriculum / metrics`
  - all are `dict[str, XxxCfg]`

## Migration gotchas

- Do not keep IsaacLab-style nested classes such as `RewardsCfg` or `ObservationsCfg`.
- Do not add manager-conversion bridge layers.
- When overriding `events`, explicitly confirm whether the default `reset_scene_to_default` should be preserved.
- Derive episode step count from `sim.mujoco.timestep * decimation` instead of carrying over assumptions from the old engine.

## Common replacements

- `ManagerBasedRLEnv` -> `ManagerBasedRlEnv`
- `ManagerBasedRLEnvCfg` -> `ManagerBasedRlEnvCfg`
- Gym step-return semantics can still be aligned, but `timeout` / `terminated` are explicitly separated by the terminations manager.

## Recommended reading

- Manager dictionary structure: `references/mjlab-api-managers.md`
- Scene configuration: `references/mjlab-api-scene.md`
- Built-in term helpers: `references/mjlab-mdp-builtins.md`
