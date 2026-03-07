# mjlab.scene API Reference

## Sources

- `mjlab/docs/source/api/scene.rst`
- `mjlab/docs/source/scene.rst`
- `mjlab/docs/source/migration_isaac_lab.rst`
- `mjlab/src/mjlab/scene/__init__.py`

## Public API

- `mjlab.scene.Scene`
- `mjlab.scene.SceneCfg`

## How to use it during migration

- When migrating IsaacLab's `InteractiveSceneCfg`, the main destination in mjlab is `SceneCfg`.
- `SceneCfg` uniformly describes:
  - `terrain`
  - `entities`
  - `sensors`
  - `num_envs`
  - `env_spacing`

## Runtime semantics

- The scene attaches every entity to the same root `MjSpec`.
- Elements inside an entity automatically receive a prefixed namespace:
  - for example, if the entity name is `robot`, then `base_link` becomes `robot/base_link`
- Terrain does not receive an entity prefix and stays in the global namespace.
- `scene.compile()` runs before `Simulation` uploads the result to MuJoCo Warp.
- `scene.initialize()` resolves indices, allocates state buffers, and initializes rendering resources.
- Parallel environments currently share the same `MjModel`:
  - they can run different states in parallel
  - but they **cannot** use different meshes / geoms / kinematic trees per environment
- If the source task depends on per-environment heterogeneous geometry or assets, the migration must be explicitly redesigned rather than copied by default.

## Migration gotchas

- Remove the `prim_path` / `ENV_REGEX_NS` / USD scene-graph mindset.
- Do not rely on IsaacLab's scene-cloning mechanism anymore. mjlab parallel environments are managed through `num_envs` and `env_origins`.
- If reset logic previously wrote root state back to an environment origin, it should now read `scene.env_origins`.
- In mjlab, a fixed-base entity participates in multi-environment placement through a mocap wrapper:
  - it is only moved to the correct per-env location after the reset event runs
  - without an appropriate reset term, the fixed-base entity stays at the global origin
- If the task needs cross-entity edits, such as cross-entity tendons / ropes / global sites / shared constraints, prefer `SceneCfg.spec_fn`.

## Scene access patterns

- `env.scene["robot"]`: entity
- `env.scene["terrain_scan"]`: explicitly registered sensor
- `env.scene["robot/trunk_imu"]`: builtin sensor auto-discovered from entity XML

## Easy-to-miss design points

- `SceneCfg.spec_fn` is appropriate for global assembly that a single `EntityCfg` cannot express:
  - cross-entity tendons
  - worldbody-level sites / bodies
  - shared constraints and extra structures across multiple entities
- When migrating IsaacLab, if part of the source logic conceptually belongs to the scene-wide assembly stage, do not force it back into a single entity cfg.

## Recommended reading

- Environment shell: `references/mjlab-api-envs.md`
- Sensors: `references/mjlab-api-sensor.md`
- Terrain: `references/mjlab-api-terrains.md`
