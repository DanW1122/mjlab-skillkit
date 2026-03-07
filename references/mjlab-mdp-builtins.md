# Reference for built-in `mjlab.envs.mdp` helpers

## Sources

- `mjlab/docs/source/actions.rst`
- `mjlab/docs/source/observations.rst`
- `mjlab/docs/source/rewards.rst`
- `mjlab/docs/source/events.rst`
- `mjlab/docs/source/metrics.rst`
- `mjlab/docs/source/terminations.rst`
- `mjlab/docs/source/randomization.rst`
- `mjlab/src/mjlab/envs/mdp/__init__.py`
- `mjlab/src/mjlab/envs/mdp/actions/*.py`
- `mjlab/src/mjlab/envs/mdp/observations.py`
- `mjlab/src/mjlab/envs/mdp/rewards.py`
- `mjlab/src/mjlab/envs/mdp/events.py`
- `mjlab/src/mjlab/envs/mdp/terminations.py`

## Action cfgs (most common)

- `JointPositionActionCfg`
- `JointVelocityActionCfg`
- `JointEffortActionCfg`
- `TendonLengthActionCfg`
- `TendonVelocityActionCfg`
- `TendonEffortActionCfg`
- `SiteEffortActionCfg`
- `DifferentialIKActionCfg`

Common parameters:

- `entity_name`
- `actuator_names`
- `scale`
- `offset`
- `use_default_offset`
- `clip`

## Observation helpers

- `base_lin_vel`
- `base_ang_vel`
- `projected_gravity`
- `joint_pos_rel`
- `joint_vel_rel`
- `last_action`
- `generated_commands`
- `builtin_sensor`
- `height_scan`

Additional notes:

- The observation pipeline is `compute -> noise -> clip -> scale -> delay -> history`.
- Both group level and term level can configure history / delay / corruption.

## Reward helpers

- `is_alive`
- `is_terminated`
- `joint_torques_l2`
- `joint_vel_l2`
- `joint_acc_l2`
- `action_rate_l2`
- `action_acc_l2`
- `joint_pos_limits`
- `flat_orientation_l2`
- `posture` (class)
- `electrical_power_cost` (class)

## Event helpers

- `randomize_terrain`
- `reset_scene_to_default`
- `reset_root_state_uniform`
- `reset_root_state_from_flat_patches`
- `reset_joints_by_offset`
- `push_by_setting_velocity`
- `apply_body_impulse`
- `apply_external_force_torque`

## Metrics helpers

- `mean_action_acc` (available in newer upstream mjlab releases)

Additional notes:

- Upstream mjlab now also uses `MetricsTermCfg(func=mdp.mean_action_acc)` in velocity-style tasks.
- Treat metrics as logging/debugging terms, not as reward terms with hidden weights.

## Termination helpers

- `time_out`
- `bad_orientation`
- `root_height_below_minimum`
- `nan_detection`

## `dr` domain randomization

- Entry point: `mjlab.envs.mdp.dr`
- Attach it through `EventTermCfg(func=dr.xxx, mode=...)`
- Typical targets include friction, mass, joint damping, joint armature, camera FOV / intrinsics, and more

## Important note about commands

- `mjlab.envs.mdp` **does not provide one unified generic commands module**
- Command terms are usually implemented inside each task:
  - velocity tasks: `mjlab.tasks.velocity.mdp.velocity_command.UniformVelocityCommandCfg`
  - tracking: `mjlab.tasks.tracking.mdp.commands.MotionCommandCfg`
  - manipulation: `mjlab.tasks.manipulation.mdp.commands.LiftingCommandCfg`
- A command is updated not only on its `resampling_time_range`, but is also **force-resampled on every episode reset**
- If the source task is sensitive to command initialization at reset, verify that behavior separately instead of checking only the time-based sampling window

## Important note about event modes

- `step` events are real first-class event terms in mjlab, not just a custom loop pattern.
- Some built-ins, such as `apply_body_impulse`, are intended for `mode="step"` rather than `mode="interval"` or `mode="reset"`.

## Migration suggestions

- Reuse `mjlab.envs.mdp` and task-local existing helpers first
- Add custom terms only when neither the local docs nor the task implementation already contains an equivalent
