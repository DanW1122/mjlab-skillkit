# mjlab.entity API Reference

## Sources

- `mjlab/docs/source/api/entity.rst`
- `mjlab/src/mjlab/entity/__init__.py`
- `mjlab/docs/source/migration_isaac_lab.rst`

## Public API

- `mjlab.entity.Entity`
- `mjlab.entity.EntityCfg`
- `mjlab.entity.EntityArticulationInfoCfg`
- `mjlab.entity.EntityIndexing`
- `mjlab.entity.EntityData`

## How to use it during migration

- `EntityCfg` is the scene-level configuration entry for a single entity, such as a robot or object.
- `EntityData` is the main runtime access point for state reads.
- Managers / rewards / observations / events often locate an entity via `SceneEntityCfg("robot")`, then read `env.scene["robot"].data`.

## Typical runtime data

- Root state: `root_link_pos_w`, `root_link_quat_w`
- Rigid-link state: `body_link_pos_w`, `body_link_quat_w`
- Joint state: `joint_pos`, `joint_vel`

## Field migration reminders

- `asset_name` -> `entity_name`
- `body_pos_w` -> `body_link_pos_w`
- `body_quat_w` -> `body_link_quat_w`
- `body_lin_vel_w` -> `body_link_lin_vel_w`
- `body_ang_vel_w` -> `body_link_ang_vel_w`

## Migration gotchas

- Do not keep IsaacLab's dual `prim/entity` naming scheme.
- The entity key in `SceneCfg` is the stable reference name used later by managers / sensors / rewards.
- Newer upstream mjlab adds `EntityCfg.sort_actuators`. Use it only when `model.ctrl` must follow joint/tendon/site definition order rather than actuator config order.
- If action slicing or actuator mapping depends on control index order, verify whether the default actuator declaration order or `sort_actuators=True` matches the source behavior.
- If an entity uses STL / OBJ / mesh assets, split them by default into:
  - visual mesh
  - collision geoms
- If a non-convex mesh participates in collision, prefer convex decomposition or multiple primitive / convex geoms instead of using it directly as a single collision geom.

## Recommended reading

- Scene namespace: `references/mjlab-api-scene.md`
- `SceneEntityCfg` in managers: `references/mjlab-api-managers.md`
- Mesh import rules: `references/mjlab-mesh-import-guidelines.md`
