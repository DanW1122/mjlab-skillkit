# mjlab.managers API Reference

## Sources

- `mjlab/docs/source/api/managers.rst`
- `mjlab/docs/source/actions.rst`
- `mjlab/docs/source/observations.rst`
- `mjlab/docs/source/rewards.rst`
- `mjlab/docs/source/commands.rst`
- `mjlab/docs/source/events.rst`
- `mjlab/docs/source/curriculum.rst`
- `mjlab/docs/source/metrics.rst`
- `mjlab/docs/source/terminations.rst`
- `mjlab/src/mjlab/managers/__init__.py`

## Public API

### Basic

- `ManagerBase`
- `ManagerTermBase`
- `ManagerTermBaseCfg`
- `SceneEntityCfg`

### Action / Observation / Reward / Termination

- `ActionManager`, `ActionTerm`, `ActionTermCfg`
- `ObservationManager`, `ObservationGroupCfg`, `ObservationTermCfg`
- `RewardManager`, `RewardTermCfg`
- `TerminationManager`, `TerminationTermCfg`

### Command / Curriculum / Event / Metrics

- `CommandManager`, `NullCommandManager`, `CommandTerm`, `CommandTermCfg`
- `CurriculumManager`, `NullCurriculumManager`, `CurriculumTermCfg`
- `EventManager`, `EventMode`, `EventTermCfg`
- `MetricsManager`, `NullMetricsManager`, `MetricsTermCfg`

## Core migration rules

- All managers live directly on the top level of `ManagerBasedRlEnvCfg`.
- The shape must be `dict[str, XxxTermCfg]`.
- Do not keep manager `@configclass` definitions.
- Do not use bridge converters to turn class-style managers back into dictionaries.

## Minimum model for each manager type

- `observations`
  - The value is `ObservationGroupCfg`.
  - The group then holds `terms: dict[str, ObservationTermCfg]`.
- `actions`
  - The value is `ActionTermCfg`.
  - The action manager slices policy outputs in registration order.
- `rewards`
  - The value is `RewardTermCfg`.
  - Every item has a `weight`.
- `terminations`
  - The value is `TerminationTermCfg`.
  - `time_out=True` means truncation, not failure.
- `commands`
  - The value is `CommandTermCfg`.
  - A command term is a class, not a plain function.
- `events`
  - The value is `EventTermCfg`.
  - Common `mode` values are `startup` / `reset` / `interval` / `step`.
  - Also check `interval_range_s`, `is_global_time`, and `min_step_count_between_reset` instead of assuming IsaacLab-style reset/interval semantics.
- `curriculum`
  - The value is `CurriculumTermCfg`.
- `metrics`
  - The value is `MetricsTermCfg`.

## Migration gotchas

- Observation groups and observation terms form a two-level structure. Do not flatten all observation terms into one dictionary.
- Commands in mjlab are class-based terms. Do not force them into the reward / termination function pattern.
- Empty `commands` / `curriculum` / `metrics` automatically use Null managers. There is no need to create empty shell classes.

## Recommended reading

- Built-in helpers: `references/mjlab-mdp-builtins.md`
- Top-level EnvCfg fields: `references/mjlab-api-envs.md`
