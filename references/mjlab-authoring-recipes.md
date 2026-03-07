# mjlab Authoring Recipes

This file gives the AI a minimal “write code directly” routing guide: when you see a common mjlab coding request, first decide **where to edit**, **which references to read**, and **what to reuse first**.

## Usage principles

- Choose the **smallest edit surface** first
- Reuse the **closest existing task example** first
- Reuse **`mjlab.envs.mdp` helpers** first
- Only add task-local helpers / classes when existing patterns are not enough

## Quick file-placement guide

| Goal | Preferred edit location | Second choice |
| --- | --- | --- |
| Adjust observations | `observations` inside the task's `env_cfg.py` / `velocity_env_cfg.py` / `tracking_env_cfg.py` | task-local `mdp/observations.py` |
| Adjust rewards | `rewards` inside the task's `env_cfg.py` | task-local `mdp/rewards.py` |
| Adjust actions | `actions` inside the task's `env_cfg.py` | task-local action cfg / helper |
| Adjust commands | `commands` inside the task's `env_cfg.py` | task-local `mdp/commands.py` or `velocity_command.py` |
| Adjust events / DR / reset | `events` inside the task's `env_cfg.py` | task-local `mdp/events.py` / `mjlab.envs.mdp.events` |
| Adjust terminations | `terminations` inside the task's `env_cfg.py` | task-local `mdp/terminations.py` |
| Add a sensor | `scene.sensors` or sensors on the robot cfg | sensor helper / task-local observation wiring |
| Adjust terrain | `scene.terrain` / terrain generator config | curriculum term |
| Create a new robot-specific task cfg | `tasks/<task>/config/<robot>/env_cfgs.py` | base `*_env_cfg.py` |
| Create a new base task factory | `tasks/<task>/*_env_cfg.py` | task-local `mdp/*` |
| Add RL config | `tasks/<task>/config/<robot>/rl_cfg.py` | task-specific runner |
| Register a task | `tasks/<task>/config/<robot>/__init__.py` | task registry helper |

## Recipe 1: Add a reward / penalty

### Read first

- `references/mjlab-mdp-builtins.md`
- `references/mjlab-api-managers.md`

### Priority order

1. Check whether `mjlab.envs.mdp.rewards.*` can express it directly.
2. If not, check the current task's `mdp/rewards.py`.
3. If that is still not enough, add a task-local reward helper.

### Direct edit pattern

- Add a new `RewardTermCfg` to the target env cfg's `rewards` dictionary.
- If you are only adjusting weights or parameters, **do not** create a new function.

### Typical requests

- “Add action smoothness” -> first try `action_rate_l2` / `action_acc_l2`
- “Add joint regularization” -> first try `joint_pos_limits` / `joint_vel_l2`
- “Add a survival reward” -> first try `is_alive`

## Recipe 2: Add an observation

### Read first

- `references/mjlab-api-managers.md`
- `references/mjlab-mdp-builtins.md`

### Priority order

1. Add an `ObservationTermCfg` to the existing `actor` / `critic` group's `terms`.
2. Reuse an existing helper whenever possible.
3. Add a task-local observation helper only when the required state-read logic is genuinely missing.

### Direct edit pattern

- Decide first whether it belongs in `actor`, `critic`, or both.
- Decide first whether it needs noise / scale / history / delay.
- If actor and critic differ only by noise, prefer reusing the same term structure.

## Recipe 3: Add contact / raycast / camera

### Read first

- `references/mjlab-api-scene.md`
- `references/mjlab-api-sensor.md`
- `references/mjlab-mdp-builtins.md`

### Priority order

1. Wire the sensor into `scene.sensors` first.
2. Then connect it into observations / rewards / events.
3. If the XML already contains a builtin sensor, prefer reading that builtin sensor directly.

### Direct edit pattern

- Contact: usually used by rewards / terminations / metrics
- RayCast: usually used for `height_scan` in observations
- Camera: usually used for observations / visualization / export; verify first whether it really needs to go into the policy

## Recipe 4: Add an event / reset / domain randomization term

### Read first

- `references/mjlab-mdp-builtins.md`
- `references/mjlab-api-sim.md`
- `references/mjlab-api-managers.md`

### Priority order

1. Check `mjlab.envs.mdp.events.*` first.
2. For domain randomization, check `mjlab.envs.mdp.dr.*` first.
3. Add a task-local helper only when task-specific reset logic is really needed.

### Direct edit pattern

- Reset behavior: `mode="reset"`
- Initialization randomization: `mode="startup"`
- Periodic perturbation: `mode="interval"`

### Typical requests

- “Push the robot every few seconds” -> `push_by_setting_velocity`
- “Randomize root pose / joint offsets on reset” -> `reset_root_state_uniform` / `reset_joints_by_offset`
- “Randomize friction / mass / COM” -> `dr.geom_friction` / `dr.body_mass` / `dr.body_com_offset`

## Recipe 5: Add a command

### Read first

- `references/mjlab-api-managers.md`
- `references/mjlab-mdp-builtins.md`

### Priority order

1. Reuse an existing command class from the current task first.
2. If it is a genuinely new task objective, write a new `CommandTermCfg` + `CommandTerm`.

### Direct edit pattern

- Register it in the `commands` dictionary.
- Then expose it to actor / critic through `generated_commands` in observations.

### Note

- Commands in mjlab are usually class-based. Do not write them with the mental model of reward functions.

## Recipe 6: Create a new robot-specific env cfg

### Read first

- `references/mjlab-authoring-workflow.md`
- `references/mjlab-api-tasks.md`
- existing `tasks/<task>/config/<robot>/env_cfgs.py`

### Priority order

1. Reuse the base `make_xxx_env_cfg()` first.
2. Then apply sensor / weight / body / site / geom-name adjustments in the robot-specific `env_cfgs.py`.
3. Do not copy the entire base env factory unless the task semantics are already different.

### Direct edit pattern

- adjust `cfg.scene.entities`
- adjust `cfg.scene.sensors`
- adjust `cfg.rewards[...]`
- adjust `cfg.events[...]`
- adjust `cfg.viewer`
- adjust `cfg.commands[...]`

## Recipe 7: Create a complete new task

### Read first

- `references/mjlab-authoring-workflow.md`
- `references/mjlab-api-envs.md`
- `references/mjlab-api-tasks.md`
- `references/mjlab-api-rl.md`

### Minimal implementation chain

1. Write the base env factory.
2. Write the robot-specific env cfg.
3. Write the RL cfg.
4. Write `register_mjlab_task(...)`.

### Default structure

- `tasks/<task>/<task>_env_cfg.py`
- `tasks/<task>/mdp/*.py`
- `tasks/<task>/config/<robot>/env_cfgs.py`
- `tasks/<task>/config/<robot>/rl_cfg.py`
- `tasks/<task>/config/<robot>/__init__.py`

## Recipe 8: Unsure whether a new helper is needed

### Default decision rule

- Only changing existing config fields -> do not create one
- Only changing weights / names / ranges -> do not create one
- Only combining existing helpers -> do not create one
- Only when there is genuinely new state-read logic / reward logic / command-sampling logic -> create one

### Minimization principle

- add a term first
- then add a task-local function
- add a class only as the last step

## Minimal checks before finishing

- all managers are still dictionaries
- the edit surface stays as small as possible
- references point to public `mjlab.*` APIs or the closest existing task example
- you did not write abstractions first and only later look for how to use them
