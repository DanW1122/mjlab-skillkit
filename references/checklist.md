# 迁移检查清单

## 编辑前

- 确认源任务路径和目标路径。
- 确认用户选择的目录结构模式：`preserve-layout` 或 `mjlab-layout`。
- 根据仓库规范确认迁移范围和不可编辑区域。
- 确认 `mujocolab/mjlab` 源码目录是只读参考，不在本次编辑范围内。
- 阅读 `references/docs-interface-diff.md`，确认本次迁移覆盖接口差异点。
- 阅读 `references/mjlab-api-pack.md`，确认要用到的模块在 mjlab 官方 API 列表内。
- 阅读 `references/official-migrating-from-isaaclab.md` 并确认本次 case 没有违背其边界说明。
- 明确本次迁移采用官方 manager 配置：`dict[str, XxxTermCfg]`（不保留 manager `@configclass`）。
- 明确 IsaacLab 工程特有脚手架是否保留；默认答案应为“不保留”。
- 确认目标模块风格（dataclass + dict-manager，或该项目约定的等价风格）。
- 明确迁移目标是“mjlab 原生实现 + 行为等价”，不是“代码形态逐行一致”。

## 迁移中

- 保持一比一函数映射与调用顺序。
- 保留注释与 TODO 语义。
- 若模式为 `mjlab-layout`：对齐 `anymal_c_velocity` 组织方式（独立任务包 + `mjlab.tasks` entry point + `register_mjlab_task`）。
- 若模式为 `preserve-layout`：保持原目录树，仅迁移 API/配置语义和注册接线。
- 对照相似 `mjlab/**` 实现并沿用现有表达方式。
- 若接口差异导致无法一比一搬运，允许内部实现调整，但必须收敛到 mjlab 原生 API。
- 把 Isaac Lab 的 `@configclass` manager 逐项改为 `dict[str, XxxTermCfg]`。
- 覆盖全部 manager：`rewards/observations/actions/commands/terminations/events/curriculum`。
- 若目标风格要求 dict manager，则把 manager 定义改为工厂函数返回字典。
- 若是 dataclass EnvCfg/SceneCfg 路径，确认 manager 字段全部用 `field(default_factory=make_xxx)` 初始化。
- 确认未使用桥接工具：`manager_terms_to_dict`、`AttrDict`、`observation_terms_from_class`。
- 用 mjlab 等价字段/import 替换 IsaacLab 专有接口（注意 `RlEnv` 命名细节）。
- 将 `InteractiveSceneCfg` + `prim_path` 思路替换为 `SceneCfg` + `entities/sensors`。
- Contact 传感器优先迁移到 `mjlab.utils.spec_config.ContactSensorCfg`（或项目等价封装）。
- 检查是否需要显式设置/保留 `scale_rewards_by_dt`、`is_finite_horizon`、`metrics` 等 mjlab EnvCfg 字段语义。
- 不迁移 Isaac Sim UI extension 代码（如 `omni.ext` / `omni.ui` 示例入口）。
- 保持 rewards/observations/actions/commands/reset/termination/curriculum 行为等价。
- 保持兜底逻辑与源实现一致（不多加、不漏加）。
- 当源工程没有兜底时，确认没有新增 `try/except` 宽泛包裹、`hasattr` 兜底分支、静默默认值回退。
- 确认没有新增兼容层/桥接层代码（compat/adapter/shim/wrapper for old API）。
- 当源工程没有 `raise`/`assert` 时，确认没有新增额外异常抛出或断言。
- 保留原注释/TODO；若做注释 mjlab 化改写，仅允许术语/API 名替换，不改语义。

## 迁移后清理

- 删除过期 import 和无用转换/兼容辅助函数。
- 确认没有 Isaac/IsaacLab 残留（import、符号、注释、旧字段名）。
- 确认没有改动 `mujocolab/mjlab` 源码文件。
- 确认最终目录组织与用户选定模式一致。
- 确认 manager 配置已符合目标 mjlab 原生风格（不保留 class-wrapper 桥接）。
- 确认没有 manager `@configclass` 残留，且 manager 最终注入值均为字典。
- 确认未保留 IsaacLab extension 脚手架文件（例如 `ui_extension_example.py`、`config/extension.toml`）。
- 确认原注释仍在（含 TODO），仅发生必要的 mjlab 术语替换。
- 确认最终实现是 mjlab 原生代码路径，不依赖 IsaacLab 兼容壳层。
- 确认源项目特有语义命名仍保留（如 `hack_generator`），除非是强制字段映射重命名。

## 验证

- 对修改过的 Python 文件运行 `python -m py_compile <changed_file>.py`。
- 验证 manager 字段初始化正确（适用时使用 `field(default_factory=make_xxx)`）。
- 验证 EnvCfg 注入的是 manager 字典对象，而不是 manager class 实例。
- 验证运行时环境类与配置类命名已正确替换：`RLEnv` -> `RlEnv`。
- 验证仅保留 MuJoCo 相关仿真配置，且无 PhysX/render_interval/physics_material 遗留。
- 验证任务注册符合目标项目约定，并优先使用 `register_mjlab_task` + `mjlab.tasks` entry point。
- 验证训练/评估入口使用正确 task id 和 env cfg（按项目组织选择注册或直接构造）。
- 运行一次关键字排查，确认迁移目标代码中没有非必要 `omni.` / `isaacsim.` 依赖残留。
- 运行一次关键字排查，确认没有新增兜底痕迹（如 `hasattr(`、宽泛 `except Exception`、静默 `return default`）。
- 运行一次关键字排查，确认没有新增异常/断言痕迹（`raise `、`assert `）超出源工程范围。

## 行为等价闸门

- 奖励项与权重等价。
- 观测项、顺序与 corruption 行为等价。
- 动作缩放和 actuator 映射等价。
- 命令采样与参数范围等价。
- reset/event 随机化与终止条件等价。
- curriculum 推进逻辑等价。
- 若实现细节与源代码不同，逐项给出“差异点 -> 等价性依据”。

## 卡住时

- 先查 `mujocolab/mjlab` 的 `src/mjlab/tasks/`。
- 仍无法覆盖时到官方渠道反馈：
  - Issues：`https://github.com/mujocolab/mjlab/issues`
  - Discussions：`https://github.com/mujocolab/mjlab/discussions`
