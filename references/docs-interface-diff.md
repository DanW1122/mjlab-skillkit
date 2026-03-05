# 本地 docs 接口差异（mjlab vs IsaacLab）

本文件基于本地文档对照提炼接口差异，优先级高于零散经验规则。

## 本次对照的本地文档

`mjlab`：

- `mjlab/docs/source/migration_isaac_lab.rst`
- `mjlab/docs/source/environment_config.rst`
- `mjlab/docs/source/scene.rst`
- `mjlab/docs/source/training/rsl_rl.rst`
- `mjlab/docs/source/api/envs.rst`
- `mjlab/docs/source/api/managers.rst`
- `mjlab/docs/source/api/tasks.rst`

`IsaacLab`：

- `IsaacLab/docs/source/tutorials/03_envs/create_manager_rl_env.rst`
- `IsaacLab/docs/source/tutorials/03_envs/register_rl_env_gym.rst`
- `IsaacLab/docs/source/tutorials/02_scene/create_scene.rst`
- `IsaacLab/docs/source/api/lab/isaaclab.envs.rst`
- `IsaacLab/docs/source/api/lab/isaaclab.scene.rst`
- `IsaacLab/docs/source/setup/quickstart.rst`

## 接口差异总览

## 1) 环境类命名

- IsaacLab：
  - 运行时环境类：`ManagerBasedRLEnv`
  - 配置类：`ManagerBasedRLEnvCfg`
- mjlab：
  - 运行时环境类：`ManagerBasedRlEnv`
  - 配置类：`ManagerBasedRlEnvCfg`

迁移要点：`RLEnv` -> `RlEnv` 的命名变化要全量替换。

## 2) Manager 配置结构（强制）

- IsaacLab：常见为嵌套 `@configclass`（如 `RewardsCfg`, `ObservationsCfg`）。
- mjlab：`ManagerBasedRlEnvCfg` 中直接注入 manager 字典：
  - `observations: dict[str, ObservationGroupCfg]`
  - `actions: dict[str, ActionTermCfg]`
  - `rewards: dict[str, RewardTermCfg]`
  - `terminations/events/commands/curriculum/metrics` 也都是字典。

迁移要点：所有 manager 必须改为 `dict[str, XxxTermCfg]`，不保留 manager `@configclass`。

## 3) Scene/世界建模方式

- IsaacLab：`InteractiveSceneCfg` + `prim_path` + `ENV_REGEX_NS` 克隆场景。
- mjlab：`SceneCfg` + `entities/sensors`，无 USD `prim_path` 体系。
  - scene 组合时会给实体自动加前缀命名空间（例如 `robot/base_link`）。

迁移要点：彻底移除 `prim_path`/USD 场景图思路，改为 MuJoCo 场景组合表达。

## 4) 传感器接口

- IsaacLab：`isaaclab.sensors.ContactSensorCfg`（与 prim 体系绑定）。
- mjlab：优先 `mjlab.utils.spec_config.ContactSensorCfg`（官方迁移页推荐），也可能使用项目封装的 `mjlab.sensor.ContactSensorCfg`。

迁移要点：contact 传感器通常挂在机器人配置（例如 `replace(robot_cfg, sensors=(sensor,))`）。

## 5) 注册与任务发现

- IsaacLab：`gym.register(...)` + `gym.make(...)` 是主流教程路径。
- mjlab：`register_mjlab_task(...)` 注册任务，`task_id` 绑定 `env_cfg/play_env_cfg/rl_cfg/runner_cls`。

迁移要点：优先 `register_mjlab_task`；不要通过修改 `mjlab` 上游源码硬编码任务。

## 6) 训练入口与参数覆盖

- IsaacLab：常见 `isaaclab.sh -p scripts/...`，并通过 gym task id 启动。
- mjlab：常见 `uv run train <TaskId>` / `uv run play <TaskId>`。
  - CLI 通过 `tyro` 覆盖配置，参数使用连字符（`--num-envs`）。
  - 布尔参数要求显式 `True/False`。

迁移要点：把原训练脚本入口切换到 mjlab 训练/播放命令体系。

## 7) 额外配置语义（mjlab 文档明确）

`ManagerBasedRlEnvCfg` 中常用但在 IsaacLab 迁移时容易遗漏的字段：

- `is_finite_horizon`
- `scale_rewards_by_dt`（默认会按 `step_dt` 缩放奖励）
- `metrics` manager（字典）
- 默认 `events` 常含 `reset_scene_to_default`

迁移要点：迁移时明确这些字段语义，不要只迁 rewards/obs/actions。

## 8) 工程脚手架差异

- IsaacLab 工程里常见 `omni.*`/`isaacsim.*` 的 extension/UI 脚手架。
- mjlab 迁移默认不需要这类脚手架。

迁移要点：`ui_extension_example.py`、`config/extension.toml` 等默认不保留（除非用户明确要求）。

## 9) 兜底与注释策略（迁移纪律）

- 源工程没有兜底时，不新增兜底分支。
- 兜底行为必须一比一对齐源逻辑，不能额外加“保险代码”。
- 原注释与 TODO 必须保留；仅允许最小必要的 mjlab 化术语替换。
- 明确拒绝兼容层：不新增 compat/adapter/shim 桥接代码。
- 源工程没有的 `raise`/`assert` 不新增。

## 10) “mjlab 化 + 等价性”原则

- 迁移目标是 mjlab 原生实现，不是保留 IsaacLab 代码形态。
- 因接口差异出现内部实现变化是允许的。
- 判定标准不是“写法是否一样”，而是“最终功能与行为是否一致”。
- 若出现实现差异，必须在迁移说明中记录差异点和等价性依据。

## 迁移执行建议

1. 先按本文件做接口级清单对照，再开始代码改写。
2. 每改完一个 manager，立即验证其最终注入类型是字典。
3. 每改完一个 scene/sensor 模块，立即排查 `prim_path`/`ENV_REGEX_NS`/`omni.` 残留。
4. 完成后执行 `references/checklist.md` 的全量核对。
