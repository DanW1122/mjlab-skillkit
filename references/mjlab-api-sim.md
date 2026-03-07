# mjlab.sim API Reference

## Sources

- `mjlab/docs/source/api/sim.rst`
- `mjlab/docs/source/randomization.rst`
- `mjlab/src/mjlab/sim/__init__.py`

## Public API

- `mjlab.sim.Simulation`
- `mjlab.sim.SimulationCfg`
- `mjlab.sim.MujocoCfg`
- `mjlab.sim.TorchArray`
- `mjlab.sim.WarpBridge`

## Most common configuration entry points during migration

- `sim.mujoco.timestep`
- `sim.mujoco.iterations`
- `sim.mujoco.ls_iterations`

These fields are usually enough to cover the core simulation parameters in an IsaacLab task migration.

## Migration gotchas

- mjlab uses the MuJoCo / MuJoCo Warp stack and does not keep PhysX parameter blocks.
- Do not continue migrating `render_interval`, PhysX materials, or USD-related physics config.
- Physics frequency is jointly determined by `sim.mujoco.timestep * decimation`.

## Randomization entry points

- Domain randomization is attached through `EventTermCfg` + `mjlab.envs.mdp.dr`.
- Common `mode` values are:
  - `startup`
  - `reset`
  - `interval`

## Common `dr` categories

- geom: `geom_friction`, `geom_pos`, `geom_quat`, `geom_rgba`, `geom_size`
- body: `body_mass`, `body_com_offset`, `body_pos`, `body_quat`
- joint: `joint_damping`, `joint_armature`, `joint_friction`
- camera: `cam_fovy` / `cam_intrinsic`

## Recommended reading

- Event configuration and reset helpers: `references/mjlab-mdp-builtins.md`
- Manager event structure: `references/mjlab-api-managers.md`
