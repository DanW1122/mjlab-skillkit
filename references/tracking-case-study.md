# Tracking Migration Case Study (`whole_body_tracking` -> `mjlab.tasks.tracking`)

This file compares a real IsaacLab tracking task against the tracking implementation in `mjlab`, file by file.

It is a concrete example of the **general complex-task migration manual** in `references/complex-task-migration-playbook.md`, and should not be understood as meaning this skill only serves tracking.

The goal is not to “copy mjlab”, but to learn:

- which changes are **mechanical migration**
- which changes are **interface reorganization**
- which changes are **semantic redistribution**
- which places require a separate “variant completeness” check

---

## Files Compared

### IsaacLab / `whole_body_tracking`

- `whole_body_tracking/source/whole_body_tracking/whole_body_tracking/tasks/tracking/tracking_env_cfg.py`
- `whole_body_tracking/source/whole_body_tracking/whole_body_tracking/tasks/tracking/mdp/commands.py`
- `whole_body_tracking/source/whole_body_tracking/whole_body_tracking/tasks/tracking/mdp/observations.py`
- `whole_body_tracking/source/whole_body_tracking/whole_body_tracking/tasks/tracking/mdp/rewards.py`
- `whole_body_tracking/source/whole_body_tracking/whole_body_tracking/tasks/tracking/mdp/terminations.py`
- `whole_body_tracking/source/whole_body_tracking/whole_body_tracking/tasks/tracking/config/g1/flat_env_cfg.py`
- `whole_body_tracking/source/whole_body_tracking/whole_body_tracking/tasks/tracking/config/g1/agents/rsl_rl_ppo_cfg.py`
- `whole_body_tracking/source/whole_body_tracking/whole_body_tracking/tasks/tracking/config/g1/__init__.py`

### mjlab

- `mjlab/src/mjlab/tasks/tracking/tracking_env_cfg.py`
- `mjlab/src/mjlab/tasks/tracking/mdp/commands.py`
- `mjlab/src/mjlab/tasks/tracking/mdp/observations.py`
- `mjlab/src/mjlab/tasks/tracking/mdp/rewards.py`
- `mjlab/src/mjlab/tasks/tracking/mdp/terminations.py`
- `mjlab/src/mjlab/tasks/tracking/mdp/metrics.py`
- `mjlab/src/mjlab/tasks/tracking/config/g1/env_cfgs.py`
- `mjlab/src/mjlab/tasks/tracking/config/g1/rl_cfg.py`
- `mjlab/src/mjlab/tasks/tracking/config/g1/__init__.py`

---

## One-Sentence Conclusion

This case shows that **tracking migration is not about translating one large `TrackingEnvCfg` class directly into another large class; it is about splitting the result into four layers: “base env factory + robot-specific override + RL cfg + task registration.”**

That is the most valuable mjlab pattern to learn here.

---

## 1) File-Level Mapping: Where Each Source File Gets Split To

| IsaacLab source file | mjlab landing point | Migration meaning |
| --- | --- | --- |
| `tracking_env_cfg.py` | `tracking_env_cfg.py` | Keep the task-level base MDP structure, but turn it into a factory returning `ManagerBasedRlEnvCfg` |
| `config/g1/flat_env_cfg.py` | `config/g1/env_cfgs.py` | Robot-specific config no longer relies on inheritance; it incrementally modifies a base cfg |
| `config/g1/agents/rsl_rl_ppo_cfg.py` | `config/g1/rl_cfg.py` | RL config changes from class-style config to functions returning config objects |
| `config/g1/__init__.py` (`gym.register`) | `config/g1/__init__.py` (`register_mjlab_task`) | Task registration style changes |
| `mdp/commands.py` | `mdp/commands.py` | Core command logic is mostly preserved, but the cfg style becomes dataclass + `build()` |
| `mdp/observations.py` | `mdp/observations.py` | Most changes are “same logic, different imports / types / field names” |
| `mdp/rewards.py` | `mdp/rewards.py` | Main rewards stay equivalent; contact penalties are adapted to the mjlab sensor model |
| `mdp/terminations.py` | `mdp/terminations.py` | Main termination logic stays, while math/entity APIs are replaced with mjlab equivalents |

**Migration rules:**

- First identify the “base task layer” and the “robot variant layer” in the source
- Do not force all logic into one file
- Prefer reusing the task directory structure already present in mjlab

---

## 1.5) AI Should Build a “Variant Matrix” First, Not Rush Into Code Changes

For tracking / imitation / whole-body control tasks, the safest first step is not changing imports, but listing **source variants** and **target variants** in a table.

| Semantic variant | source | mjlab | Required AI checks |
| --- | --- | --- | --- |
| base training | `G1FlatEnvCfg` + `Tracking-Flat-G1-v0` | `unitree_g1_flat_tracking_env_cfg()` + `Mjlab-Tracking-Flat-Unitree-G1` | `anchor_body_name`, `body_names`, action scale, and main reward/termination terms |
| no-state-estimation | `G1FlatWoStateEstimationEnvCfg` | `unitree_g1_flat_tracking_env_cfg(has_state_estimation=False)` | Which actor/policy observation terms are removed, not whether the names merely look similar |
| low-freq | `G1FlatLowFreqEnvCfg` + `G1FlatLowFreqPPORunnerCfg` | No direct equivalent in the current tracking registration | You must explicitly say “intentionally not migrated” or “still needs migration”; do not silently drop it |
| play / evaluation | The source has no separately registered env-cfg class | `play_env_cfg=unitree_g1_flat_tracking_env_cfg(play=True)` | Whether `episode_length_s`, randomization, `sampling_mode`, and `push_robot` are handled separately |

What this matrix is for:

- First distinguish **which variants are source class-inheritance variants**
- Then distinguish **which variants are target runtime-mode variants**
- Finally decide:
  - which ones need to become independent task ids
  - which ones can collapse into function parameters
  - which ones must be explicitly documented as “not migrated yet”

**Special note:**

- In `mjlab`, `play` is usually more than “just run a script once”; it often becomes a distinct config branch through `play_env_cfg`.
- Therefore, tracking tasks cannot validate only the training env; **you must validate both the training env and the play env**.

---

## 2) How the Manager Structure Migrates

### IsaacLab shape

`whole_body_tracking` uses:

- `CommandsCfg`
- `ActionsCfg`
- `ObservationsCfg.PolicyCfg`
- `ObservationsCfg.PrivilegedCfg`
- `EventCfg`
- `RewardsCfg`
- `TerminationsCfg`
- `CurriculumCfg`

At its core, this is a stack of nested `@configclass` definitions.

### mjlab shape

`mjlab` tracking changes this to:

- `observations = {"actor": ObservationGroupCfg(...), "critic": ObservationGroupCfg(...)}`
- `actions = {"joint_pos": JointPositionActionCfg(...)}`
- `commands = {"motion": MotionCommandCfg(...)}`
- `events = {...}`
- `rewards = {...}`
- `terminations = {...}`

### The most critical migration points

| IsaacLab | mjlab | Explanation |
| --- | --- | --- |
| `PolicyCfg` | `actor` | Name adjusted to mjlab / RSL-RL conventions |
| `PrivilegedCfg` | `critic` | Privileged observations move into the critic group |
| `ObsGroup.__post_init__` | `ObservationGroupCfg(...)` arguments | `enable_corruption` / `concatenate_terms` are specified directly on the group cfg |
| `CommandsCfg.motion = ...` | `commands["motion"] = ...` | Class wrapper is decomposed into a dict term |

**Migration rules:**

- In tracking tasks, the easiest things to miss are **policy -> actor** and **privileged -> critic**
- This is not a simple rename; it usually also affects:
  - actor/critic inputs in training config
  - the term-removal logic for no-state-estimation variants

---

## 3) Scene Migration: Not “Rename Fields”, but “Change the World Model”

### Source

The scene in `whole_body_tracking` uses:

- `InteractiveSceneCfg`
- `TerrainImporterCfg`
- `prim_path`
- `light`
- `sky_light`
- `contact_forces = ContactSensorCfg(prim_path="{ENV_REGEX_NS}/Robot/.*", ...)`

### mjlab

The base tracking env in `mjlab` uses:

- `SceneCfg(...)`
- `TerrainEntityCfg(terrain_type="plane")`
- `entities`
- `sensors`
- `ViewerConfig`
- `SimulationCfg(MujocoCfg(...))`

### The real migration moves to learn

1. **Delete** the USD / `prim_path` mindset
2. **Rebuild** the scene as `SceneCfg` + `entities` + `sensors`
3. Treat **visual decoration** (`light`/`sky_light`) as non-core logic and do not migrate it by default
4. **Redesign the contact semantics**
   - the source task’s `contact_forces` is a scene sensor that scans the whole robot
   - in mjlab, tracking uses a more explicit `self_collision` sensor

**Migration rules:**

- Do not begin by asking “how do I keep `prim_path`?”
- Begin by asking “what entities / sensors / terrain does this scene actually need in mjlab?”

---

## 4) Commands: The Core of Tracking Migration, Not Just Field Renaming

### Obvious `MotionCommandCfg` changes

| IsaacLab | mjlab | Explanation |
| --- | --- | --- |
| `asset_name` | `entity_name` | Forced field mapping |
| `body_names: list[str]` | `body_names: tuple[str, ...]` | More stable cfg data structure |
| `@configclass` | `@dataclass(kw_only=True)` | Configuration style switch |
| `class_type = MotionCommand` | `build(self, env)` | mjlab command cfg produces a command term through `build()` |
| no `sampling_mode` | has `sampling_mode` | mjlab explicitly supports `"adaptive" / "uniform" / "start"` |
| visualizer cfg | `viz: VizCfg` | Debug-visualization interface is reorganized |

### More importantly: randomization semantics did not disappear, they were redistributed

In both the source and mjlab, `MotionCommand` performs the following inside `_resample_command(...)`:

- `pose_range`
- `velocity_range`
- `joint_position_range`
- writing the reference frame back to root / joint state

This means:

- Some behaviors that looked like “reset/randomization events” in IsaacLab may still remain inside command logic in mjlab
- **Do not** see source startup/reset perturbations and mechanically demand that the target expose them one by one under `events`

**Migration rules:**

- For tracking tasks, first inspect which randomization responsibilities `MotionCommand` itself carries
- Only then decide which source events need to remain as independent `events[...]`

---

## 5) Events: Not One-to-One Renaming, but “Reorganize by Intent”

### Source events

`whole_body_tracking` contains:

- `physics_material`
- `add_joint_default_pos`
- `base_com`
- `push_robot`

### mjlab tracking counterpart

`mjlab` tracking contains:

- `push_robot`
- `base_com`
- `encoder_bias`
- `foot_friction`

### This is not a simple rename; it is a real change in semantic landing point

| source | mjlab | Migration interpretation |
| --- | --- | --- |
| `physics_material` / `randomize_rigid_body_material` | `foot_friction` / `dr.geom_friction` | Under MuJoCo, you no longer preserve the PhysX material concept; instead, you randomize geom friction directly |
| `add_joint_default_pos` | `encoder_bias` + `MotionCommand.joint_position_range` | The source task’s default-joint-pose perturbation is not necessarily still a standalone event in mjlab; inspect it by final point of effect |
| `base_com` | `base_com` / `dr.body_com_offset` | Mostly a same-semantic migration |
| `push_robot` | `push_robot` | Preserved directly |

**Migration rules:**

- First align “what is being randomized”, then decide whether it belongs in:
  - `events[...]`
  - `MotionCommand._resample_command(...)`
  - sensor / action bias logic

**Do not** force each source event name to appear verbatim in the target.

---

## 6) Rewards / Terminations: Main Objectives Usually Stay, Contact Terms Change Most Easily

### Terms that mostly stay consistent

In both the source and mjlab, these core tracking terms remain aligned:

- `motion_global_anchor_pos`
- `motion_global_anchor_ori`
- `motion_body_pos`
- `motion_body_ori`
- `motion_body_lin_vel`
- `motion_body_ang_vel`
- `action_rate_l2`
- `joint_limit`

Termination terms also mostly map directly:

- `time_out`
- `anchor_pos`
- `anchor_ori`
- `ee_body_pos`

### Biggest change: the contact penalty

source:

- `undesired_contacts`
- depends on the `contact_forces` scene sensor
- filters unwanted contact parts by body name

mjlab:

- `self_collisions`
- depends on the `self_collision` sensor
- uses `self_collision_cost(...)` to accumulate force history or `found`

### Migration rules

- Do not just rename the function when you see a contact penalty
- First confirm whether the source penalizes:
  - self-collision
  - non-foot ground contact
  - collisions of certain end effectors
- Then decide whether the target needs:
  - a `self_collision` sensor
  - a `feet_ground_contact` sensor
  - or a more general contact sensor + custom reward

If the source penalizes “ground contact outside the feet”, then you **cannot** blindly replace it with `self_collision_cost`.

---

## 7) Robot-Specific Variants: The Part Most Easily Missed in Migration

### G1 variants in `whole_body_tracking`

- `G1FlatEnvCfg`
- `G1FlatWoStateEstimationEnvCfg`
- `G1FlatLowFreqEnvCfg`

### Existing G1 variants in mjlab

- `unitree_g1_flat_tracking_env_cfg()`
- `unitree_g1_flat_tracking_env_cfg(has_state_estimation=False)`

### Key observations

1. The **base G1 variant** has already been migrated into a robot-specific cfg function
2. The **no-state-estimation variant** also has an equivalent version
3. The **low-freq variant** has **no direct counterpart** in the current mjlab tracking registration

### Why the low-freq variant matters

The source `G1FlatLowFreqEnvCfg` / `G1FlatLowFreqPPORunnerCfg` do not just rename things; together they modify:

- `decimation`
- `rewards.action_rate_l2.weight`
- `num_steps_per_env`
- `gamma`
- `lam`

### Why the play variant must also be checked separately

In this case, the source and target land “play” in different places:

- In `whole_body_tracking`, play behaves more like a **script-driven runtime mode**
- In `mjlab`, play is a **`play_env_cfg` prepared at `register_mjlab_task(...)` registration time**

The play override in `mjlab` explicitly does at least the following:

- `episode_length_s = int(1e9)`, i.e. approximately infinite horizon
- `cfg.observations["actor"].enable_corruption = False`
- `cfg.events.pop("push_robot", None)`
- `motion_cmd.pose_range = {}`
- `motion_cmd.velocity_range = {}`
- `motion_cmd.sampling_mode = "start"`

**Migration rules:**

- Do not assume that “the source play script can run” means the target already has equivalent play config
- For `mjlab-layout`, prefer encoding play semantics into `play_env_cfg`
- If the source scatters play behavior across scripts, migration must decide:
  - whether it moves into `play_env_cfg`
  - or stays in evaluation/demo scripts
  - but it must be recorded explicitly, not left implicit

**Variant completeness rules:**

- For tracking tasks, source variants must be checked one by one to confirm they were all migrated
- If the target side has no low-freq variant, explicitly record whether that is:
  - intentionally not migrated
  - or accidentally missing

---

## 8) Registration and Training Config: Class Entry Points -> Instance Entry Points

### source

- `gym.register(...)`
- `env_cfg_entry_point`
- `rsl_rl_cfg_entry_point`

### mjlab

- `register_mjlab_task(...)`
- pass directly:
  - `env_cfg=...`
  - `play_env_cfg=...`
  - `rl_cfg=...`
  - `runner_cls=...`

### PPO config migration pattern

source:

- `policy = RslRlPpoActorCriticCfg(...)`

mjlab:

- `actor = RslRlModelCfg(...)`
- `critic = RslRlModelCfg(...)`

**Migration rules:**

- The structure looks different, but the hyperparameters are usually preserved one by one
- During migration, the main checks are:
  - hidden dims
  - activation
  - noise std
  - entropy coef
  - learning rate
  - gamma / lam
  - max_iterations / save_interval / num_steps_per_env

## 8.5) Treat Target Tests as “Migration Contracts”, Not Just Regression Tests

If the target repository already has tests for the same task family, AI should treat those tests as **migration completion conditions**, not as extra checks run after the fact.

Using `mjlab/tests/test_tracking_task.py` as an example, tracking migration exposes at least these contracts:

1. **The task must have a `motion` command**
   - and its type must be `MotionCommandCfg`
2. **The task must have a `self_collision` sensor**
   - meaning the contact semantics have landed in the sensor design the target expects
3. **The no-state-estimation variant must remove the correct actor observations**
   - not just delete a few terms randomly, but explicitly remove the terms that depend on state estimation
4. **Play mode must disable RSI randomization**
   - `pose_range == {}`
   - `velocity_range == {}`
5. **Play mode must switch `sampling_mode`**
   - for tracking, the required value here is `sampling_mode == "start"`
6. **Robot-specific parameters must still hold**
   - for example, G1 tracking action scale must still equal `G1_ACTION_SCALE`

**Migration rules:**

- For tracking / imitation / whole-body control:
  - read the source first
  - then read the target implementation
  - finally read the target tests
- If the target does not yet have tests, still extract these assertions into your own migration self-checklist.

In other words, **tests are not “extra information”; they are formal statements of the target style’s required behavior.**

---

## 9) The “Tracking Migration Order” Suggested by This Case

Recommended order:

1. Migrate `MotionCommandCfg` and the command runtime first
2. Then migrate observations (because many of them depend on command outputs)
3. Then migrate rewards / terminations
4. Then migrate scene / contact-sensor design
5. Then migrate robot-specific overrides
6. Then read target tests and extract the behavior contract the target has already committed to
7. Finally migrate RL cfg / task registration / play variants

Why:

- In tracking tasks, command is the center of all state-alignment logic
- If the command layer is not aligned yet, later obs/reward/done code may “look like it compiles” while actually being completely wrong
- Tests often constrain variant completeness, registration completeness, and play semantics exactly where migration tends to drift

---

## 10) The Most Common Migration Mistakes

### Mistake 1: Translating the entire `TrackingEnvCfg` directly into one huge dataclass

Better approach:

- base task factory: `make_tracking_env_cfg()`
- robot-specific override: `unitree_g1_flat_tracking_env_cfg()`

### Mistake 2: Migrating only the main task and not checking variants

At minimum, check:

- base variant
- no-state-estimation
- play variant
- low-freq / other special variants

### Mistake 3: Mechanically mapping source events one by one

You first need to see where the final randomization/perturbation semantics actually land:

- event
- command resample
- sensor bias

### Mistake 4: Replacing a contact penalty with self collision immediately

You must first confirm which contact type the source is actually penalizing.

### Mistake 5: Migrating only env cfg, not registration and runner cfg

Tracking tasks often end up in this state:

- env cfg appears finished
- but the task is not registered
- play cfg is missing
- variants are not connected

### Mistake 6: Failing to treat target tests as requirement documents

Typical consequences:

- the main variant runs, but the no-state-estimation variant forgot to remove observations
- play mode still samples random frames, so demo behavior becomes unstable
- task-id registration is incomplete, so training/evaluation entry points no longer line up

---

## 11) General Migration Strategy Reverse-Engineered from This Case

If you are not facing tracking specifically, you can still reuse the same thinking:

1. First identify the **task-level base factory**
2. Then identify the **robot/task variant layer**
3. Then identify whether **command is the central object**
4. Then inspect whether source event/randomization logic must split into different landing points
5. Finally verify variant completeness

---

## 12) Final Conclusion

The most valuable lesson in this case is not any single API name, but two migration disciplines:

1. **Structurally**: migrate from a “large all-in-one inherited configclass” to “base factory + variant override + registry”
2. **Semantically**: upgrade from “field-by-field comparison” to “reorganization by behavioral responsibility”

For tracking / imitation / whole-body control tasks, these two principles matter more than any single field mapping.
