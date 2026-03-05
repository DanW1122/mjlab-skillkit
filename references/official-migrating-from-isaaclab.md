# Migrating from Isaac Lab（官方说明吸收版）

## 状态说明

- 该迁移指南仍在持续更新（work in progress）。
- 遇到未覆盖模式、边界条件或新 case，建议反馈到：
  - Issues：`https://github.com/mujocolab/mjlab/issues`
  - Discussions：`https://github.com/mujocolab/mjlab/discussions`

## TL;DR

- 大多数 Isaac Lab 的 manager-based 任务配置可以通过小改动迁移到 mjlab。
- 整体 MDP 结构不变：`rewards / observations / actions / commands / terminations / events / curriculum`。
- 环境基类概念接近，但命名细节有差异（例如 `RlEnv` 命名）。
- 最大差异是配置风格：
  - Isaac Lab 偏向嵌套 `@configclass`
  - mjlab 偏向 `dict[str, XxxTermCfg]`（可程序化构造、合并、生成）
- 这类迁移以“机械改写”为主，不是逻辑重写。

## 关键差异

## 1) Import 与命名风格

常见示例：

```python
# Isaac Lab
from isaaclab.envs import ManagerBasedRLEnv

# mjlab（运行时 + 配置）
from mjlab.envs import ManagerBasedRlEnv, ManagerBasedRlEnvCfg
```

- 注意 `RlEnv` 的命名细节（`Rl` 而非 `RL`）。
- 迁移时区分：
  - 运行时环境类：`ManagerBasedRLEnv` -> `ManagerBasedRlEnv`
  - 配置类：`ManagerBasedRLEnvCfg` -> `ManagerBasedRlEnvCfg`

## 2) 配置结构：`@configclass` -> 字典

Isaac Lab：

```python
@configclass
class RewardsCfg:
  motion_global_anchor_pos = RewTerm(...)
  motion_global_anchor_ori = RewTerm(...)
```

mjlab：

```python
rewards = {
  "motion_global_anchor_pos": RewardTermCfg(...),
  "motion_global_anchor_ori": RewardTermCfg(...),
}
```

- 该模式对全部 manager 都适用：`rewards / observations / actions / commands / terminations / events / curriculum`。
- 设计背景可参考 mjlab PR：`#292`。

## 3) Scene 配置简化为 MuJoCo 原生表达

- 不再依赖 Omniverse/USD 场景图，不再管理 `prim_path`。
- 资产基于 MuJoCo（MJCF），并通过 MjSpec modifier dataclass 应用修改。
- lights/materials/textures/sensors 在 `SceneCfg` 与 robot config 里表达。
- `asset_name` 在迁移中统一为 `entity_name`。

参考模式（简化示例）：

```python
from dataclasses import replace

from mjlab.scene import SceneCfg
from mjlab.asset_zoo.robots.unitree_g1.g1_constants import get_g1_robot_cfg
from mjlab.utils.spec_config import ContactSensorCfg
from mjlab.terrains import TerrainEntityCfg

self_collision_sensor = ContactSensorCfg(
  name="self_collision",
  subtree1="pelvis",
  subtree2="pelvis",
  data=("found",),
  reduce="netforce",
  num=10,
)

g1_cfg = replace(get_g1_robot_cfg(), sensors=(self_collision_sensor,))

scene = SceneCfg(
  terrain=TerrainEntityCfg(terrain_type="plane"),
  entities={"robot": g1_cfg},
)
```

## 对照学习样例

- Isaac Lab 实现（Beyond Mimic）：`https://github.com/HybridRobotics/whole_body_tracking`
- mjlab 对应实现：`https://github.com/mujocolab/mjlab`

重点对照：

- manager 字典如何镜像原 configclass 语义。
- reward/observation/command/termination 逻辑如何保持一致。
- scene/asset 如何用纯 MuJoCo 表达。

## 迁移核对（官方思路）

1. Base class 与 imports  
将 Isaac Lab 的 import 替换为对应 mjlab import（命名大小写也要对齐）。

2. Manager 配置  
把每个 `@configclass` manager 变成 `dict[str, XxxTermCfg]`，并传入 `ManagerBasedRlEnvCfg` 或项目等价入口。

3. Scene 与 assets  
用 `SceneCfg` + entities/sensors 替代 `InteractiveSceneCfg` + `prim_path` 体系。

4. Sensors 与 contact  
将 Isaac Lab 的 contact sensor 配置迁移到 `mjlab.utils.spec_config.ContactSensorCfg`（或项目提供的等价封装），并挂到机器人配置。

5. RL 入口与注册  
确认训练/评估入口使用正确 task id 与 env cfg。根据项目组织选择 `register_mjlab_task`、entry point 或项目既有注册器。

## 实战建议

- 先对齐 physics 与 observations，再处理视觉相关效果。
- 卡住时优先查看 `mjlab` 仓库中的 `src/mjlab/tasks/` 现成任务。
- 若官方文档未覆盖当前 case，直接发 issue/discussion，避免在项目内发明私有兼容层。
