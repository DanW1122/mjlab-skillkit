# Migration Quick Reference (Compressed)

This page contains only the **most easily missed rules and the ones most worth scanning before you start editing**.

## One Line Per Pitfall

- `episode_length_s` **does not automatically create a timeout termination**; if episodes should end on time, you usually still need to preserve/add an explicit `time_out` term.
- `events` are not just `startup / reset / interval`; also pay attention to semantics such as `step`, `interval(is_global_time=True)`, and `reset(min_step_count_between_reset=...)`.
- A custom `command` is not finished just by turning it into a class; the cfg needs `build(env)`, and the term also needs `_resample_command`, `_update_command`, `_update_metrics`, plus a `command` property.
- Reset/eval logic for rough-terrain tasks is often not a one-shot `reset_root_state_uniform`; you frequently need to distinguish flat-patch reset, terrain-level placement, and whether curriculum is skipped during play/eval.
- `SceneEntityCfg` and regex targets are usually bound once at manager initialization time; if body/geom/site naming must change, fix it during scene assembly rather than expecting runtime rebinding.

## Quick Triage

If your task satisfies any of the following, it is worth checking all five items above one by one:

- it has `episode_length_s`, and timeout behavior matters
- it has complex event/randomization logic
- it has a custom command term
- it has rough terrain / terrain curriculum
- it has heavy use of `SceneEntityCfg` and regex matching for body/geom/site names

## Recommended Companion Reading

- Overall migration notes: `references/official-migrating-from-isaaclab.md`
- Complex-task migration: `references/complex-task-migration-playbook.md`
- Checklist: `references/checklist.md`
