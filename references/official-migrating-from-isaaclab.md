# Migrating from Isaac Lab (Official Notes Digest)

## Status Notes

- This migration guide is still being continuously updated (work in progress).
- If you encounter an uncovered pattern, edge condition, or new case, consider reporting it to:
  - Issues: `https://github.com/mujocolab/mjlab/issues`
  - Discussions: `https://github.com/mujocolab/mjlab/discussions`

## TL;DR

- Most manager-based Isaac Lab task configurations can be migrated to mjlab with relatively small changes.
- The overall MDP structure stays the same: `rewards / observations / actions / commands / terminations / events / curriculum`.
- The environment base-class concept is similar, but naming details differ (for example `RlEnv` naming).
- The biggest difference is configuration style:
  - Isaac Lab leans toward nested `@configclass`
  - mjlab leans toward `dict[str, XxxTermCfg]` (which can be built, merged, and generated programmatically)
- This kind of migration is mainly “mechanical rewriting”, not logic redesign.
- If you only want the easiest high-value pitfalls first, read: `references/migration-gotchas.md`

## Key Differences

## 1) Import and Naming Style

Common example:

```python
# Isaac Lab
from isaaclab.envs import ManagerBasedRLEnv

# mjlab (runtime + config)
from mjlab.envs import ManagerBasedRlEnv, ManagerBasedRlEnvCfg
```

- Pay attention to the `RlEnv` naming detail (`Rl`, not `RL`).
- During migration, distinguish:
  - runtime environment class: `ManagerBasedRLEnv` -> `ManagerBasedRlEnv`
  - configuration class: `ManagerBasedRLEnvCfg` -> `ManagerBasedRlEnvCfg`

## 2) Configuration Structure: `@configclass` -> Dicts

Isaac Lab:

```python
@configclass
class RewardsCfg:
  motion_global_anchor_pos = RewTerm(...)
  motion_global_anchor_ori = RewTerm(...)
```

mjlab:

```python
rewards = {
  "motion_global_anchor_pos": RewardTermCfg(...),
  "motion_global_anchor_ori": RewardTermCfg(...),
}
```

- This pattern applies to all managers: `rewards / observations / actions / commands / terminations / events / curriculum`.
- For design background, see mjlab PR: `#292`.

## 3) Scene Configuration Is Simplified into Native MuJoCo Expression

- It no longer depends on the Omniverse/USD scene graph and no longer manages `prim_path`.
- Assets are based on MuJoCo (MJCF), with changes applied through MjSpec modifier dataclasses.
- Lights/materials/textures/sensors are expressed in `SceneCfg` and robot config.
- During migration, `asset_name` is normalized to `entity_name`.

Reference pattern (simplified example):

```python
from dataclasses import replace

from mjlab.scene import SceneCfg
from mjlab.asset_zoo.robots.unitree_g1.g1_constants import get_g1_robot_cfg
from mjlab.utils.spec_config import ContactSensorCfg
from mjlab.terrains import TerrainEntityCfg

self_collision_sensor = ContactSensorCfg(
  name="self_collision",
  subtree1="pelvis",
  subtree2="pelvis",
  data=("found",),
  reduce="netforce",
  num=10,
)

g1_cfg = replace(get_g1_robot_cfg(), sensors=(self_collision_sensor,))

scene = SceneCfg(
  terrain=TerrainEntityCfg(terrain_type="plane"),
  entities={"robot": g1_cfg},
)
```

## Study Examples

- Isaac Lab implementation (Beyond Mimic): `https://github.com/HybridRobotics/whole_body_tracking`
- mjlab counterpart implementation: `https://github.com/mujocolab/mjlab`
- General complex-task migration playbook compiled in this repo: `references/complex-task-migration-playbook.md`
- Local close-reading comparison compiled in this repo: `references/tracking-case-study.md`

Key things to compare:

- how manager dicts mirror original `configclass` semantics
- how reward/observation/command/termination logic remains consistent
- how scene/assets are expressed in pure MuJoCo
- how target-repo tests encode variant completeness and play semantics as executable constraints

If you are migrating a complex task, read `references/complex-task-migration-playbook.md` first; if you are migrating tracking / imitation / whole-body control, then use `references/tracking-case-study.md` as a hands-on migration template.

### AI-Specific Reminder (General to Complex Tasks)

- First split the task into four layers:
  - base task env
  - robot/task variant
  - RL cfg
  - registration / play entry
- Draw a **variant matrix** before touching code; do not stare only at the main variant.
- Verify both `env_cfg` and `play_env_cfg`:
  - in mjlab, play is often an explicit config branch, not just a script parameter.
- Read the target task’s `__init__.py` registration file together with related `tests/`:
  - the registry tells you which entry points exist
  - the tests tell you which behaviors are considered mandatory
- First determine whether the central object is command / commands / the task-core runtime:
  - if command handles resample / RSI / reference-state write-back,
  - do not mechanically flatten source reset/events into target `events[...]`
- `policy -> actor` and `privileged -> critic` are not just naming changes:
  - you must also verify RL model inputs and term removal in no-state-estimation variants.
- For low-freq / special-runner variants, do not inspect only env cfg:
  - also verify `decimation`, `action_rate_l2`, `num_steps_per_env`, `gamma`, and `lam`.

### Tracking-Case-Specific Reminder

- For tracking tasks, you can directly treat `mjlab/tests/test_tracking_task.py` as an acceptance template:
  - the `motion` command must exist
  - the `self_collision` sensor must exist
  - play mode must disable RSI and switch to `sampling_mode="start"`

## Migration Verification (Official Mindset)

1. Base classes and imports
Replace Isaac Lab imports with the corresponding mjlab imports (including exact capitalization/naming).

2. Manager configuration
Convert each manager `@configclass` into `dict[str, XxxTermCfg]`, then pass it into `ManagerBasedRlEnvCfg` or the project’s equivalent entry point.

3. Scene and assets
Use `SceneCfg` + entities/sensors instead of the `InteractiveSceneCfg` + `prim_path` system.

4. Sensors and contact
Migrate Isaac Lab contact-sensor configuration to `mjlab.utils.spec_config.ContactSensorCfg` (or the project’s equivalent wrapper), then attach it to robot config.

5. RL entry points and registration
Confirm training/evaluation entry points use the correct task id and env cfg. Depending on project organization, use `register_mjlab_task`, entry points, or the project’s existing registrar.

6. Variant completeness
If the source has derived modes such as no-state-estimation / low-freq / play / eval, confirm one by one whether the target side is:
- already migrated as an independent task id
- collapsed into function parameters
- or explicitly documented as not yet migrated

7. Validate play configuration separately
For tasks with both training and evaluation entry points, do not validate only the training env; separately verify under play mode:
- episode length
- observation corruption
- event randomization
- command sampling mode
- RSI/randomization ranges

## Additional High-Value Differences Identified in This Comparison

1. **Fixed-base entity placement depends on the reset event**

   - In mjlab, fixed-base entities participate in multi-environment placement through mocap wrapping.
   - That means “just putting the entity into the scene” is not enough; if the reset event is not wired correctly, it may remain at the world origin.

2. **Current multi-environment execution shares the same `MjModel`**

   - You can parallelize different states, but you cannot assume each env can use a different mesh / geom / kinematic tree.
   - If the source task depends on env-level heterogeneous assets, migration requires explicit redesign.

3. **Cross-entity assembly fits better in `SceneCfg.spec_fn`**

   - For cross-entity tendons, shared sites, or worldbody-level auxiliary structures, do not force them back into a single entity cfg.
   - That logic is closer to mjlab’s scene-level spec editing.

4. **`history_length` for contact sensors often needs to align with `decimation`**

   - For short-pulse contacts such as self-collision / illegal contact, policy reads may miss the contact entirely unless substep history is preserved.

5. **Commands are force-resampled on reset**

   - When migrating command-heavy tasks, do not only align `resampling_time_range`; also verify command initialization semantics at the reset boundary.

## Practical Advice

- Align physics and observations first, then handle visual effects.
- When stuck, first inspect ready-made tasks in `mjlab` under `src/mjlab/tasks/`.
- For tracking / imitation tasks, also inspect related `tests/` and treat test assertions as migration contracts.
- If official docs do not cover the current case, open an issue/discussion directly rather than inventing a private compatibility layer inside the project.
