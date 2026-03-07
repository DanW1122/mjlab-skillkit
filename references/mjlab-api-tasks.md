# mjlab.tasks.registry API Reference

## Sources

- `mjlab/docs/source/api/tasks.rst`
- `mjlab/src/mjlab/tasks/registry.py`
- `mjlab/src/mjlab/tasks/velocity/config/g1/__init__.py`
- `mjlab/src/mjlab/tasks/tracking/config/g1/__init__.py`

## Public API

- `register_mjlab_task`
- `list_tasks`
- `load_env_cfg`
- `load_rl_cfg`
- `load_runner_cls`

## How to use it during migration

- The task registration entry point is `mjlab.tasks.registry.register_mjlab_task`.
- A task id usually binds:
  - `env_cfg`
  - `play_env_cfg`
  - `rl_cfg`
  - `runner_cls`

## Registration style

- The common pattern is to register directly inside the task config package's `__init__.py`.
- Example pattern:
  - `task_id="Mjlab-Velocity-Rough-Unitree-G1"`
  - `env_cfg=...`
  - `play_env_cfg=...(play=True)`
  - `rl_cfg=...`
  - `runner_cls=...`

## Load semantics

- `load_env_cfg(...)` / `load_rl_cfg(...)` return deep copies.
- That means runtime edits do not pollute the original config stored in the registry.

## Migration gotchas

- Prefer explicit project-local registration instead of hardcoding tasks into upstream `mjlab`.
- Do not default to IsaacLab's `gym.register(...)` path unless the target project explicitly requires gym compatibility.
- Task id naming should follow the target project's existing naming scheme.

## Recommended reading

- Training runner: `references/mjlab-api-rl.md`
- Environment cfg: `references/mjlab-api-envs.md`
