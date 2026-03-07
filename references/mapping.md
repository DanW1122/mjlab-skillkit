# IsaacLab -> mjlab Mapping

Start with the default mappings below, then fine-tune them against the actual mjlab module paths in the target repository.

## Alignment with the Official Migration Page

- Detailed explanation: `references/official-migrating-from-isaaclab.md`
- Local docs comparison: `references/docs-interface-diff.md`
- mjlab API reference pack: `references/mjlab-api-pack.md`
- Key takeaways:
  - the overall manager-based MDP structure stays the same;
  - the biggest difference is `@configclass` -> dictionary config (this is mandatory);
  - scene modeling moves to pure MuJoCo expression and no longer depends on USD / `prim_path`.

## Manager Configs (Official Mandatory Style)

- IsaacLab manager `@configclass` definitions must be converted to dictionaries: `dict[str, XxxTermCfg]`.
- You must cover every manager:
  - `rewards`
  - `observations`
  - `actions`
  - `commands`
  - `terminations`
  - `events`
  - `curriculum`
- After migration, no manager `@configclass` definitions may remain (unless the class is not itself a manager).
- Prefer factory functions (for example `make_rewards()`) that build dictionaries and inject them into EnvCfg.

## Project-Level Migration Style (Official Recommendation)

Reference `https://github.com/mujocolab/anymal_c_velocity`:

- Keep the target repository as a standalone task package; do not modify `mujocolab/mjlab` source.
- Declare the `mjlab` dependency in `pyproject.toml`.
- Register the task-package entrypoint via `[project.entry-points."mjlab.tasks"]`.
- Inside the task package, use `register_mjlab_task(...)` to register each task ID (train / play configs).

## Project File Keep / Drop Mapping (IsaacLab -> mjlab)

- Usually dropped by default (unless the user explicitly asks to keep them):
  - `ui_extension_example.py` and similar `omni.ext` / `omni.ui` extension example files
  - `config/extension.toml` (Isaac extension manifest)
  - `setup.py` used only for Isaac Sim extension packaging
  - Scripts used only for Isaac Sim IDE environment injection (for example `.vscode/tools/setup_vscode.py`)
- Usually kept and migrated:
  - task / env / mdp logic files (`rewards` / `observations` / `actions` / `commands` / ...)
  - robot resources and MJCF / URDF assets that still carry value
  - training and evaluation entrypoints (rewired to the corresponding mjlab entrypoint / registration flow)

## Directory Layout Strategy Mapping

- `preserve-layout`:
  - Keep the original directory tree and module paths unchanged.
  - Only replace IsaacLab APIs with mjlab APIs and hook mjlab registration into the existing entrypoint.
  - The project's existing registration module may be reused; adding `src/<task_pkg>/` is not required.
- `mjlab-layout`:
  - Reorganize into an `anymal_c_velocity` style task-package layout (recommended for consistency).
  - Recommended minimal skeleton:
    - `src/<task_pkg>/__init__.py` (task registration)
    - `src/<task_pkg>/env_cfgs.py` (environment config)
    - `src/<task_pkg>/rl_cfg.py` (RL config)
    - `src/<task_pkg>/<robot_or_assets>/...` (robot definitions and MJCF assets)
  - Configure `[project.entry-points."mjlab.tasks"]` in `pyproject.toml`.

## Imports

- Runtime environment class:
  - `isaaclab.envs.ManagerBasedRLEnv` -> `mjlab.envs.ManagerBasedRlEnv`
- Environment config class:
  - `isaaclab.envs.ManagerBasedRLEnvCfg` -> `mjlab.envs.ManagerBasedRlEnvCfg`
- `isaaclab.managers.RewardTermCfg` -> `mjlab.managers.reward_manager.RewardTermCfg`
- `isaaclab.managers.ObservationTermCfg` -> `mjlab.managers.observation_manager.ObservationTermCfg`
- `isaaclab.managers.ObservationGroupCfg` -> `mjlab.managers.observation_manager.ObservationGroupCfg`
- `isaaclab.managers.TerminationTermCfg` -> `mjlab.managers.termination_manager.TerminationTermCfg`
- `isaaclab.managers.EventTermCfg` -> `mjlab.managers.event_manager.EventTermCfg`
- `isaaclab.managers.SceneEntityCfg` -> `mjlab.managers.scene_entity_config.SceneEntityCfg`
- `isaaclab.scene.InteractiveSceneCfg` -> the target project's `mjlab` `SceneCfg` class / alias
- `isaaclab.sensors.ContactSensorCfg` -> `mjlab.utils.spec_config.ContactSensorCfg` (recommended by the official migration page)
- `isaaclab.sensors.ContactSensorCfg` -> `mjlab.sensor.ContactSensorCfg` (if the target project wraps / re-exports it)
- `isaaclab.terrains.TerrainImporterCfg` -> `mjlab.terrains.TerrainImporterCfg`
- `isaaclab.utils.noise.AdditiveUniformNoiseCfg` -> `mjlab.utils.noise.UniformNoiseCfg`

## EnvCfg Field Interface (Docs Supplement)

- `scale_rewards_by_dt`: mjlab scales rewards by `step_dt` by default.
- `is_finite_horizon`: controls time-limit semantics (truncation vs terminal).
- `metrics`: mjlab natively supports a metrics manager (dictionary).

## Comment Migration Rules

- Keep original comments and TODOs; do not delete them.
- Only make minimal terminology / API substitutions to match mjlab:
  - `RLEnv` -> `RlEnv`
  - `InteractiveSceneCfg` / `prim_path` -> `SceneCfg` / `entities`
  - `asset_name` -> `entity_name`
- If comments mention Isaac Sim / Omniverse runtime mechanisms, rewrite them to the corresponding MuJoCo / mjlab mechanism after migration.

## Term Cfg Names

- `RewTerm(...)` -> `RewardTermCfg(...)`
- `ObsTerm(...)` -> `ObservationTermCfg(...)`
- `DoneTerm(...)` -> `TerminationTermCfg(...)`
- `EventTerm(...)` -> `EventTermCfg(...)`

## Field Mappings

- `asset_name` -> `entity_name`
- `body_pos_w` -> `body_link_pos_w`
- `body_quat_w` -> `body_link_quat_w`
- `body_lin_vel_w` -> `body_link_lin_vel_w`
- `body_ang_vel_w` -> `body_link_ang_vel_w`

## Observation Group

- The `policy` group in the source task usually maps to `actor` in mjlab-style repositories.
- `critic` usually stays `critic`, unless the target repository uses a different convention.

## Scene and Sensors

- Do not use the Omniverse / USD scene graph or `prim_path` management anymore.
- Use pure MuJoCo (MJCF) to express the scene / assets, and use MjSpec modifier dataclasses for material, visual, and sensor edits.
- Remove USD / prim-path assumptions and switch to the target scene's `entities` injection pattern.
- Attach sensors through the target scene's sensor container / tuple.
- For contact sensors, prefer the official pattern of attaching them to the robot config (for example `replace(robot_cfg, sensors=(sensor,))`).
- Convert contact-filter expressions into the matching objects used by the target implementation.

## Events

Common equivalent patterns in many mjlab codebases:

- material randomization -> `randomize_field(..., field="geom_friction")`
- COM randomization -> `randomize_field(..., field="body_ipos")`
- joint bias randomization -> the matching encoder-bias / randomization function in the target MDP

## Simulation Config (MuJoCo)

In mjlab, prioritize keeping MuJoCo-specific settings:

- `self.sim.mujoco.timestep`
- `self.sim.mujoco.iterations` (optional)
- `self.sim.mujoco.ls_iterations` (optional)
- `self.decimation`
- `self.episode_length_s`

Delete IsaacLab / PhysX leftovers:

- `self.sim.physx.*`
- `self.sim.render_interval`
- `self.sim.physics_material`

Avoid fallback branches for old fields such as `hasattr`.

## Registration

- Prefer `register_mjlab_task(...)` (aligned with `anymal_c_velocity`).
- Use the `mjlab.tasks` entrypoint so mjlab can auto-discover the task package.
- Do not "hardcode" task registration by modifying internal code in `mujocolab/mjlab`.
- Use `gym.register(...)` only when the target project's legacy constraints explicitly require it.
- Task naming should follow the target project's existing conventions.

## Reference Repositories and Support

- Isaac Lab reference repository: `https://github.com/HybridRobotics/whole_body_tracking`
- mjlab reference repository: `https://github.com/mujocolab/mjlab`
- If blocked, first inspect existing implementations in `mujocolab/mjlab` under `src/mjlab/tasks/`.
- Official feedback channels:
  - Issues: `https://github.com/mujocolab/mjlab/issues`
  - Discussions: `https://github.com/mujocolab/mjlab/discussions`
