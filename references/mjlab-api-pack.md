# mjlab API 迁移包（本地 docs 提炼）

本文件汇总本地 `mjlab/docs/source/api/*.rst` 的公开模块和核心类/函数，用于迁移时“先选官方 API，再写代码”。

## 来源（本地）

- `mjlab/docs/source/api/index.rst`
- `mjlab/docs/source/api/envs.rst`
- `mjlab/docs/source/api/scene.rst`
- `mjlab/docs/source/api/sim.rst`
- `mjlab/docs/source/api/entity.rst`
- `mjlab/docs/source/api/actuator.rst`
- `mjlab/docs/source/api/sensor.rst`
- `mjlab/docs/source/api/managers.rst`
- `mjlab/docs/source/api/terrains.rst`
- `mjlab/docs/source/api/rl.rst`
- `mjlab/docs/source/api/viewer.rst`
- `mjlab/docs/source/api/tasks.rst`

## 模块总览

- `mjlab.envs`
- `mjlab.scene`
- `mjlab.sim`
- `mjlab.entity`
- `mjlab.actuator`
- `mjlab.sensor`
- `mjlab.managers`
- `mjlab.terrains`
- `mjlab.rl`
- `mjlab.viewer`
- `mjlab.tasks`

## 迁移最常用 API（优先）

## 1) 环境

- `mjlab.envs.ManagerBasedRlEnv`
- `mjlab.envs.ManagerBasedRlEnvCfg`
- `mjlab.envs.VecEnvObs`
- `mjlab.envs.VecEnvStepReturn`

## 2) 场景

- `mjlab.scene.Scene`
- `mjlab.scene.SceneCfg`

## 3) manager 相关

- `mjlab.managers.SceneEntityCfg`
- `mjlab.managers.ActionTermCfg`
- `mjlab.managers.ObservationGroupCfg`
- `mjlab.managers.ObservationTermCfg`
- `mjlab.managers.RewardTermCfg`
- `mjlab.managers.TerminationTermCfg`
- `mjlab.managers.CommandTermCfg`
- `mjlab.managers.CurriculumTermCfg`
- `mjlab.managers.EventTermCfg`
- `mjlab.managers.MetricsTermCfg`

迁移规则：以上 term cfg 在 EnvCfg 中以字典注入，不使用 manager `@configclass`。

## 4) 传感器

- `mjlab.sensor.ContactSensorCfg`
- `mjlab.sensor.ContactMatch`
- `mjlab.sensor.RayCastSensorCfg`
- `mjlab.sensor.CameraSensorCfg`

说明：若迁移路径使用官方迁移页推荐，也可在具体任务中用 `mjlab.utils.spec_config.ContactSensorCfg` 做接线。

## 5) 仿真

- `mjlab.sim.SimulationCfg`
- `mjlab.sim.MujocoCfg`

常见配置落点：`sim.mujoco.timestep/iterations/ls_iterations`。

## 6) 地形

- `mjlab.terrains.TerrainEntityCfg`
- `mjlab.terrains.TerrainGeneratorCfg`
- 以及各类子地形配置（heightfield 与 box primitive 系列）

## 7) 训练与 runner

- `mjlab.rl.MjlabOnPolicyRunner`
- `mjlab.rl.RslRlVecEnvWrapper`
- `mjlab.rl.RslRlOnPolicyRunnerCfg`
- `mjlab.rl.RslRlPpoAlgorithmCfg`
- `mjlab.rl.RslRlModelCfg`

## 8) viewer

- `mjlab.viewer.ViewerConfig`
- `mjlab.viewer.NativeMujocoViewer`
- `mjlab.viewer.ViserPlayViewer`
- `mjlab.viewer.OffscreenRenderer`

## 9) 任务注册

- `mjlab.tasks.register_mjlab_task`
- `mjlab.tasks.list_tasks`
- `mjlab.tasks.load_env_cfg`
- `mjlab.tasks.load_rl_cfg`
- `mjlab.tasks.load_runner_cls`

迁移规则：优先 `register_mjlab_task`，不要修改 mjlab 上游源码做硬编码注册。

## 使用建议

1. 每次迁移前先从本文件选定将使用的 API 模块。
2. 若代码里出现未在本文件或本地 docs 中出现的“自定义桥接层”依赖，先停下来确认是否必要。
3. 若本地 docs 与历史代码冲突，优先按本地 docs 对齐，并在迁移说明中记录取舍。
