# mjlab 迁移模式

以下模式仅作模板，需按目标仓库的命名与 import 路径调整。

## 目录结构模板（二选一）

`preserve-layout`（保留原结构）示例：

```text
your_repo/
  legacy_task_pkg/
    env_cfg.py
    mdp/
      observations.py
      rewards.py
    registry.py   # 在这里接入 mjlab 任务注册（或项目既有注册入口）
```

`mjlab-layout`（直接 mjlab 化）示例：

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

## 配置风格迁移模板（`@configclass` -> `dict`）

Isaac Lab（示意）：

```python
@configclass
class RewardsCfg:
  motion_global_anchor_pos = RewTerm(func=mdp.a, weight=0.5, params={})
  motion_global_anchor_ori = RewTerm(func=mdp.b, weight=0.5, params={})
```

mjlab（示意）：

```python
rewards = {
  "motion_global_anchor_pos": RewardTermCfg(func=mdp.a, weight=0.5, params={}),
  "motion_global_anchor_ori": RewardTermCfg(func=mdp.b, weight=0.5, params={}),
}
```

同样规则适用于 `observations/actions/commands/terminations/events/curriculum`。

官方约束：以上是 manager 配置的标准写法，迁移时必须采用，不保留 manager `@configclass`。

## 0. 项目入口与注册（对齐 anymal_c_velocity）

`pyproject.toml` 示例：

```toml
[project]
dependencies = ["mjlab>=1.1.0"]

[project.entry-points."mjlab.tasks"]
your_task_pkg = "your_task_pkg"
```

`__init__.py` 注册示例：

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

## 0.1 Contact 传感器接线（官方页常见模式）

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

## 1. Manager 工厂函数

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

## 2. Scene Dataclass 桥接

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

## 4. 继承链展开

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
