# IsaacLab -> mjlab Migration Rules

## Goal

- Migrate projects built on IsaacLab to mjlab with behavior equivalence.
- Keep rewards, observations, actions, commands, reset/events, terminations, and curriculum equivalent.
- Use `mujocolab/anymal_c_velocity` as the primary migration pattern.

## Official References

- Pattern repo: `https://github.com/mujocolab/anymal_c_velocity`
- mjlab repo (read-only reference): `https://github.com/mujocolab/mjlab`
- IsaacLab repo (source behavior reference): `https://github.com/isaac-sim/IsaacLab`

## Mandatory Constraints

- Do not modify `mujocolab/mjlab` source code.
- Must be mjlab-native after migration (no IsaacLab compatibility shell).
- No compatibility layer / adapter shim / bridge wrappers.
- No new fallback logic unless source has it.
- No new `raise`/`assert` unless source has it.
- Keep original comments/TODOs; only do minimal mjlab wording updates when necessary.
- Keep source function boundaries, call order, and config semantics.
- Keep source-specific semantic names (for example `hack_generator`) unless forced field mapping is required.

## Manager Configuration (Hard Requirement)

- Do not use manager `@configclass`.
- All managers must be dict-based: `dict[str, XxxTermCfg]`.
- Cover all manager groups: `rewards`, `observations`, `actions`, `commands`, `terminations`, `events`, `curriculum`.
- Do not use bridge helpers:
  - `manager_terms_to_dict`
  - `AttrDict`
  - `observation_terms_from_class`

## Key Mapping Reminders

- `asset_name` -> `entity_name`
- `AdditiveUniformNoiseCfg` -> `UniformNoiseCfg`
- `body_pos_w` -> `body_link_pos_w`
- `body_quat_w` -> `body_link_quat_w`
- `body_lin_vel_w` -> `body_link_lin_vel_w`
- `body_ang_vel_w` -> `body_link_ang_vel_w`

## Layout Mode (Must ask first)

- `preserve-layout`: keep original project structure.
- `mjlab-layout`: reorganize to mjlab style (recommended for new long-term projects).
- If not specified, ask user to choose before editing.

## Scope Notes

- IsaacLab-specific extension files are usually not kept (for example `ui_extension_example.py`, extension manifests, Omni UI scaffolding).
- Migration can change internal implementation due to API differences, but end behavior must remain equivalent.
