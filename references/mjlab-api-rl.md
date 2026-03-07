# mjlab.rl API Reference

## Sources

- `mjlab/docs/source/api/rl.rst`
- `mjlab/docs/source/training/rsl_rl.rst`
- `mjlab/src/mjlab/rl/__init__.py`

## Public API

- `MjlabOnPolicyRunner`
- `RslRlVecEnvWrapper`
- `RslRlOnPolicyRunnerCfg`
- `RslRlPpoAlgorithmCfg`
- `RslRlModelCfg`
- `RslRlBaseRunnerCfg`

## How to use it during migration

- After environment registration, training configs are usually handled by the `RslRlOnPolicyRunnerCfg` family.
- `RslRlVecEnvWrapper` connects mjlab environments to RSL-RL.
- If a task already has a custom runner, `runner_cls` can be specified during registration.

## CLI / training doc highlights

- Common entry points are:
  - `uv run train <TaskId>`
  - `uv run play <TaskId>`
- The CLI overrides configuration via `tyro`.
- Option names often use hyphenated forms such as `--num-envs`.
- Boolean arguments should be written explicitly as `True/False`.
- Newer upstream mjlab uses RSL-RL 5-style `RslRlModelCfg` fields such as `stochastic`, `init_noise_std`, and `noise_std_type` instead of older `distribution_cfg`-style configuration.

## Migration gotchas

- If the source task uses IsaacLab training scripts, do not mechanically preserve the old launcher and argument style.
- Prefer aligning with mjlab's organization of `train` / `play` / runner config.
- Before copying older examples, always check the local `mjlab/src/mjlab/rl/config.py` field names; RL config structure is one of the easiest places to drift across mjlab versions.

## Recommended reading

- Task registration: `references/mjlab-api-tasks.md`
- Environment cfg: `references/mjlab-api-envs.md`
