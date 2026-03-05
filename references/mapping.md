# IsaacLab -> mjlab 映射

先按下列默认映射迁移，再根据目标仓库的实际 mjlab 模块路径微调。

## 官方迁移页对齐

- 详细说明见：`references/official-migrating-from-isaaclab.md`
- 本地 docs 对照见：`references/docs-interface-diff.md`
- mjlab API 参考包：`references/mjlab-api-pack.md`
- 关键结论：
  - manager-based MDP 结构整体保持一致；
  - 最大差异是 `@configclass` -> 字典配置（这是强制项）；
  - scene 迁移到纯 MuJoCo 表达，不再依赖 USD/`prim_path`。

## Manager 配置（官方强制写法）

- 必须把 IsaacLab 的 manager `@configclass` 改成字典：`dict[str, XxxTermCfg]`。
- 必须覆盖全部 manager：
  - `rewards`
  - `observations`
  - `actions`
  - `commands`
  - `terminations`
  - `events`
  - `curriculum`
- 迁移后不得残留 manager `@configclass` 定义（除非该类不是 manager 本身）。
- 推荐使用工厂函数（例如 `make_rewards()`）生成字典并注入 EnvCfg。

## 项目级迁移方式（官方推荐）

参考 `https://github.com/mujocolab/anymal_c_velocity`：

- 目标仓库保持为独立任务包，不改 `mujocolab/mjlab` 源码。
- 在 `pyproject.toml` 中声明 `mjlab` 依赖。
- 通过 `[project.entry-points."mjlab.tasks"]` 注册任务包入口。
- 任务包内使用 `register_mjlab_task(...)` 注册各任务 ID（训练/play 配置）。

## 工程文件去留映射（IsaacLab -> mjlab）

- 默认不保留（除非用户明确要求）：
  - `ui_extension_example.py` 及同类 `omni.ext` / `omni.ui` 扩展示例文件
  - `config/extension.toml`（Isaac extension 清单）
  - 仅服务 Isaac Sim extension 打包的 `setup.py`
  - 仅服务 Isaac Sim IDE 环境注入的脚本（如 `.vscode/tools/setup_vscode.py`）
- 通常保留并迁移：
  - task/env/mdp 逻辑文件（rewards/observations/actions/commands/...）
  - 机器人资源与 MJCF/URDF 中仍有价值的模型资产
  - 训练与评估入口（改为 mjlab 对应入口/注册方式）

## 目录结构策略映射

- `preserve-layout`：
  - 保持原目录树和模块路径不变。
  - 仅替换 IsaacLab API 到 mjlab API，并在现有入口接入 mjlab 注册。
  - 可以使用项目已有注册模块，不强制新增 `src/<task_pkg>/`。
- `mjlab-layout`：
  - 重组为 `anymal_c_velocity` 风格的任务包结构（推荐统一化）。
  - 推荐最小骨架：
    - `src/<task_pkg>/__init__.py`（任务注册）
    - `src/<task_pkg>/env_cfgs.py`（环境配置）
    - `src/<task_pkg>/rl_cfg.py`（RL 配置）
    - `src/<task_pkg>/<robot_or_assets>/...`（机器人定义与 MJCF 资源）
  - 在 `pyproject.toml` 配置 `[project.entry-points."mjlab.tasks"]`。

## Imports

- 运行时环境类：
  - `isaaclab.envs.ManagerBasedRLEnv` -> `mjlab.envs.ManagerBasedRlEnv`
- 环境配置类：
  - `isaaclab.envs.ManagerBasedRLEnvCfg` -> `mjlab.envs.ManagerBasedRlEnvCfg`
- `isaaclab.managers.RewardTermCfg` -> `mjlab.managers.reward_manager.RewardTermCfg`
- `isaaclab.managers.ObservationTermCfg` -> `mjlab.managers.observation_manager.ObservationTermCfg`
- `isaaclab.managers.ObservationGroupCfg` -> `mjlab.managers.observation_manager.ObservationGroupCfg`
- `isaaclab.managers.TerminationTermCfg` -> `mjlab.managers.termination_manager.TerminationTermCfg`
- `isaaclab.managers.EventTermCfg` -> `mjlab.managers.event_manager.EventTermCfg`
- `isaaclab.managers.SceneEntityCfg` -> `mjlab.managers.scene_entity_config.SceneEntityCfg`
- `isaaclab.scene.InteractiveSceneCfg` -> 目标项目中的 `mjlab` SceneCfg 类/别名
- `isaaclab.sensors.ContactSensorCfg` -> `mjlab.utils.spec_config.ContactSensorCfg`（官方迁移页推荐）
- `isaaclab.sensors.ContactSensorCfg` -> `mjlab.sensor.ContactSensorCfg`（若目标项目做了封装/re-export）
- `isaaclab.terrains.TerrainImporterCfg` -> `mjlab.terrains.TerrainImporterCfg`
- `isaaclab.utils.noise.AdditiveUniformNoiseCfg` -> `mjlab.utils.noise.UniformNoiseCfg`

## EnvCfg 字段接口（docs 补充）

- `scale_rewards_by_dt`：mjlab 默认会按 `step_dt` 缩放 reward。
- `is_finite_horizon`：控制 time-limit 语义（truncation vs terminal）。
- `metrics`：mjlab 原生支持指标 manager（字典）。

## 注释迁移规范

- 保留原注释与 TODO，不删除。
- 仅做术语/API 的最小替换以匹配 mjlab：
  - `RLEnv` -> `RlEnv`
  - `InteractiveSceneCfg`/`prim_path` -> `SceneCfg`/`entities`
  - `asset_name` -> `entity_name`
- 注释中若提到 Isaac Sim/Omniverse 运行机制，迁移后应改为对应的 MuJoCo/mjlab 机制描述。

## Term Cfg 名称

- `RewTerm(...)` -> `RewardTermCfg(...)`
- `ObsTerm(...)` -> `ObservationTermCfg(...)`
- `DoneTerm(...)` -> `TerminationTermCfg(...)`
- `EventTerm(...)` -> `EventTermCfg(...)`

## 字段映射

- `asset_name` -> `entity_name`
- `body_pos_w` -> `body_link_pos_w`
- `body_quat_w` -> `body_link_quat_w`
- `body_lin_vel_w` -> `body_link_lin_vel_w`
- `body_ang_vel_w` -> `body_link_ang_vel_w`

## Observation Group

- 源任务里的 `policy` 组，在 mjlab 风格仓库中通常映射为 `actor`。
- `critic` 一般保持 `critic`，除非目标仓库有不同约定。

## Scene 和 Sensors

- 不再使用 Omniverse/USD 场景图与 `prim_path` 管理。
- 使用纯 MuJoCo（MJCF）表达 scene/asset，并通过 MjSpec modifier dataclass 做材质、视觉、传感器修改。
- 移除 USD/prim-path 假设，改为目标 scene 的 `entities` 注入方式。
- 通过目标 scene 的 sensor 容器/tuple 挂载传感器。
- Contact 传感器优先按官方写法接到机器人配置（例如 `replace(robot_cfg, sensors=(sensor,))`）。
- 按目标实现将 contact filter 表达式改成对应的匹配对象。

## Events

在不少 mjlab 代码库中的常见等价写法：

- material randomization -> `randomize_field(..., field="geom_friction")`
- COM randomization -> `randomize_field(..., field="body_ipos")`
- joint bias randomization -> 目标 MDP 中对应的 encoder bias/随机化函数

## 仿真配置（MuJoCo）

在 mjlab 中优先保留 MuJoCo 相关项：

- `self.sim.mujoco.timestep`
- `self.sim.mujoco.iterations`（可选）
- `self.sim.mujoco.ls_iterations`（可选）
- `self.decimation`
- `self.episode_length_s`

删除 IsaacLab/PhysX 遗留配置：

- `self.sim.physx.*`
- `self.sim.render_interval`
- `self.sim.physics_material`

避免使用 `hasattr` 之类的旧字段兜底分支。

## 注册

- 优先使用 `register_mjlab_task(...)`（对齐 `anymal_c_velocity`）。
- 通过 `mjlab.tasks` entry point 让 mjlab 自动发现任务包。
- 禁止通过修改 `mujocolab/mjlab` 内部代码来“硬编码”注册任务。
- 仅当目标项目历史包袱明确要求时才使用 `gym.register(...)`。
- 任务命名遵循目标项目既有规则。

## 对照样例与支持

- Isaac Lab 对照仓库：`https://github.com/HybridRobotics/whole_body_tracking`
- mjlab 对照仓库：`https://github.com/mujocolab/mjlab`
- 卡住时优先查看 `mujocolab/mjlab` 的 `src/mjlab/tasks/` 现成实现。
- 官方反馈渠道：
  - Issues：`https://github.com/mujocolab/mjlab/issues`
  - Discussions：`https://github.com/mujocolab/mjlab/discussions`
