# mjlab Migration Patterns

The patterns below are templates only. Adjust names and import paths to the target repository.

## Directory Layout Templates (Choose One)

`preserve-layout` example (keep the original layout):

```text
your_repo/
  legacy_task_pkg/
    env_cfg.py
    mdp/
      observations.py
      rewards.py
    registry.py   # hook mjlab task registration here (or the project's existing registration entrypoint)
```

`mjlab-layout` example (convert directly into an mjlab-style layout):

```text
your_repo/
  src/
    your_task_pkg/
      __init__.py
      env_cfgs.py
      rl_cfg.py
      your_robot/
        robot_constants.py
        xmls/
          robot.xml
          assets/
```

## Config Style Migration Template (`@configclass` -> `dict`)

Isaac Lab (schematic):

```python
@configclass
class RewardsCfg:
  motion_global_anchor_pos = RewTerm(func=mdp.a, weight=0.5, params={})
  motion_global_anchor_ori = RewTerm(func=mdp.b, weight=0.5, params={})
```

mjlab (schematic):

```python
rewards = {
  "motion_global_anchor_pos": RewardTermCfg(func=mdp.a, weight=0.5, params={}),
  "motion_global_anchor_ori": RewardTermCfg(func=mdp.b, weight=0.5, params={}),
}
```

The same rule applies to `observations/actions/commands/terminations/events/curriculum`.

Official constraint: this is the standard manager-config style, and you must use it during migration; do not keep manager `@configclass` definitions.

## 0. Project Entrypoint and Registration (Aligned with anymal_c_velocity)

`pyproject.toml` example:

```toml
[project]
dependencies = ["mjlab>=1.1.0"]

[project.entry-points."mjlab.tasks"]
your_task_pkg = "your_task_pkg"
```

`__init__.py` registration example:

```python
from mjlab.register import register_mjlab_task

register_mjlab_task(
  task_id="Mjlab-Your-Task-Id",
  env_cfg=make_env_cfg(),
  play_env_cfg=make_env_cfg(play=True),
  rl_cfg=make_rl_cfg(),
  runner_cls=YourRunner,
)
```

## 0.1 Contact Sensor Wiring (Common Pattern from the Official Docs)

```python
from dataclasses import replace

from mjlab.utils.spec_config import ContactSensorCfg

self_collision_sensor = ContactSensorCfg(
  name="self_collision",
  subtree1="pelvis",
  subtree2="pelvis",
  data=("found",),
  reduce="netforce",
  num=10,
)

robot_cfg = replace(robot_cfg, sensors=(self_collision_sensor,))
```

## 1. Manager Factory Functions

```python
from dataclasses import dataclass, field

from mjlab.managers.reward_manager import RewardTermCfg
from mjlab.managers.observation_manager import ObservationGroupCfg, ObservationTermCfg


def make_rewards() -> dict[str, RewardTermCfg]:
  return {
    "term_a": RewardTermCfg(func=mdp.term_a, weight=1.0, params={}),
  }


def make_observations() -> dict[str, ObservationGroupCfg]:
  actor_terms = {
    "obs_a": ObservationTermCfg(func=mdp.obs_a, params={}),
  }
  return {
    "actor": ObservationGroupCfg(
      terms=actor_terms,
      concatenate_terms=True,
      enable_corruption=True,
    ),
  }
```

## 2. Scene Dataclass Bridging

```python
from dataclasses import dataclass

from mjlab.scene import SceneCfg
from mjlab.sensor import ContactSensorCfg


@dataclass(kw_only=True)
class TaskSceneCfg(SceneCfg):
  robot: object | None = None
  contact_forces: ContactSensorCfg | None = None

  def __post_init__(self):
    if self.robot is not None:
      self.entities["robot"] = self.robot
    if self.contact_forces is not None:
      self.sensors = (self.contact_forces,)
```

## 3. EnvCfg Dataclass

```python
@dataclass(kw_only=True)
class TaskEnvCfg(ProjectRlEnvCfg):
  scene: TaskSceneCfg = field(default_factory=lambda: TaskSceneCfg(num_envs=4096))
  rewards: dict = field(default_factory=make_rewards)
  observations: dict = field(default_factory=make_observations)
  actions: dict = field(default_factory=make_actions)
  commands: dict = field(default_factory=make_commands)
  terminations: dict = field(default_factory=make_terminations)
  events: dict = field(default_factory=make_events)
  curriculum: dict = field(default_factory=make_curriculum)

  def __post_init__(self):
    self.decimation = 4
    self.episode_length_s = 10.0
    self.sim.mujoco.timestep = 1.0 / 50.0 / self.decimation
```

## 4. Flatten Inheritance Chains

```python
def make_base_rewards() -> dict[str, RewardTermCfg]:
  return {
    "alive": RewardTermCfg(func=mdp.is_alive, weight=0.5, params={}),
  }


def make_flat_rewards() -> dict[str, RewardTermCfg]:
  rewards = make_base_rewards()
  rewards["alive"] = RewardTermCfg(func=mdp.is_alive, weight=1.0, params={})
  rewards["flat_only"] = RewardTermCfg(func=mdp.flat_bonus, weight=0.2, params={})
  return rewards
```
