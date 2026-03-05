# 迁移规则

## 官方基线

- 官方迁移范式仓库：`https://github.com/mujocolab/anymal_c_velocity`
- mjlab API 参考仓库：`https://github.com/mujocolab/mjlab`
- IsaacLab 源行为参考仓库：`https://github.com/isaac-sim/IsaacLab`
- 官方迁移说明（持续更新）：`references/official-migrating-from-isaaclab.md`
- 本地 docs 接口差异提炼：`references/docs-interface-diff.md`
- mjlab API 迁移包：`references/mjlab-api-pack.md`

## 文档真值规则

- 优先读取迁移目标仓库本地文档（例如 `mjlab/docs` 与 `IsaacLab/docs`）。
- 本 skill 中的接口映射以本地 docs 对比结论为主，线上文档用于补充缺失信息。
- 若本地 docs 与线上文档冲突，默认先按本地 docs 版本执行，并在迁移说明里记录差异。
- 迁移前至少完成一次接口级对照：`references/docs-interface-diff.md`。

## 官方迁移说明状态

- 该迁移说明是持续更新（work in progress）的文档。
- 遇到未覆盖模式或边界情况，优先通过下列渠道补充：
  - Issues：`https://github.com/mujocolab/mjlab/issues`
  - Discussions：`https://github.com/mujocolab/mjlab/discussions`

## 目录结构选择规则（必须先确定）

- 模式 A：`preserve-layout`（保留原工程结构）
  - 保留原仓库目录结构与模块路径。
  - 迁移重点是 API/配置语义，不强制文件树重排。
- 模式 B：`mjlab-layout`（直接 mjlab 化）
  - 对齐 `anymal_c_velocity` 的目录组织与注册方式。
  - 推荐用于新任务包、长期维护统一化。
- 用户未明确时，必须先询问后再动手迁移。

## 作用范围

- 修改文件前先根据用户要求或仓库规范确认可编辑范围。
- 将 IsaacLab 源代码视为行为基准。
- 默认只编辑目标 mjlab 实现文件，除非用户明确要求改其他目录。
- 无论在何种仓库布局下，都不得改动 `mujocolab/mjlab` 源代码（包括 submodule/vendor/镜像目录）。

## IsaacLab 工程特有文件处理

- 默认不迁移 IsaacLab/Omniverse extension 脚手架文件。
- 在你的 InstinctLab 中，典型示例包括：
  - `source/instinctlab/instinctlab/ui_extension_example.py`
  - `source/instinctlab/config/extension.toml`
  - `source/instinctlab/setup.py`（若仅用于 extension 元数据打包）
  - `.vscode/tools/setup_vscode.py`（Isaac Sim 开发环境辅助）
- 若用户明确要求保留 Isaac Sim extension 能力，才单独评估是否保留；否则全部按“非迁移目标”处理。

## 核心目标

将 IsaacLab 任务/环境迁移到 mjlab，并保持以下行为完全等价：

- rewards
- observations
- actions
- commands
- terminations
- reset/events
- curriculum

迁移优先级：

1. 最终功能/行为等价（最高优先级）
2. mjlab 原生实现（必须 mjlab 化）
3. 在不冲突前两条的前提下尽量贴近源代码结构

## 强约束

- 保留源代码注释和 TODO 语义，不删除原注释。
- 注释可做最小必要的 mjlab 化改写（例如 `ManagerBasedRLEnv` -> `ManagerBasedRlEnv`、`prim_path` -> `entities`），但不改原语义。
- 默认保持函数边界与调用顺序和源实现一致。
- 不得省略原版逻辑步骤、函数边界、调用顺序、配置项。
- 不得无依据新增辅助抽象（额外继承、包装层、合并/拆分函数、大段重排）。
- 若因 mjlab 接口差异无法一比一照搬，允许最小必要实现差异，但必须保证行为等价且最终代码是 mjlab 原生表达。
- 禁止为了风格做结构性重排。
- 明确拒绝兼容层：禁止新增 compatibility layer、adapter shim、桥接包装器。
- manager 配置必须使用官方字典风格（`dict[str, XxxTermCfg]`），禁止继续使用 manager 嵌套 `@configclass`。
- 兜底/guard 逻辑必须与源行为对齐：源有则保留，源无则不加。
- 源工程没有兜底逻辑时，不得新增任何兜底分支（包括宽泛 `try/except`、`hasattr` 分支、静默降级返回默认值）。
- 源工程没有的 `raise`/`assert` 不得新增；只允许保留与迁移源一致的异常/断言行为。
- 禁止修改 mjlab 上游源码；迁移代码必须放在你的目标项目中，通过依赖方式使用 mjlab。
- 迁移后必须清理 Isaac/IsaacLab 接口残留。
- 迁移后默认不保留 Isaac Sim UI extension 相关入口和依赖（`omni.*` / `isaacsim.*` 的工程脚手架层）。
- 禁止整段原样复制源文件；必须按 mjlab 接口与目标项目结构适配。
- 保留源项目特有语义命名（例如 `hack_generator`），除非是 mjlab 明确要求的接口字段映射。

## 官方推荐迁移组织方式（对齐 anymal_c_velocity）

- 采用“独立任务项目 + 依赖 `mjlab`”模式，而不是在 `mjlab` 仓库内直接改源码。
- 在项目 `pyproject.toml` 中声明 `mjlab` 依赖。
- 通过 `[project.entry-points."mjlab.tasks"]` 暴露任务包，让 mjlab 自动发现任务。
- 在任务包 `__init__.py` 使用 `register_mjlab_task(...)` 注册任务变体。
- 该组织方式默认对应 `mjlab-layout`；`preserve-layout` 可以只借鉴 API 表达，不强制复制目录树。

## Manager 配置规则

- 必须使用返回 `dict[str, XxxTermCfg]` 的 manager 配置。
- 推荐用工厂函数构造 manager 字典，便于变体复用和覆盖。
- 若目标项目采用 dict manager 风格，则保持 manager 全字典化。
- 允许 `@dataclass` 定义主 EnvCfg 和 SceneCfg；但 manager 字段必须是字典。
- manager 字段必须使用 `field(default_factory=make_xxx)` 初始化，不得保留类式 manager 配置。
- 不要为了复用 IsaacLab class config 写法而引入桥接转换工具。
- 明确禁止桥接工具：`manager_terms_to_dict`、`AttrDict`、`observation_terms_from_class`。
- 所有 manager（`rewards/observations/actions/commands/terminations/events/curriculum`）都遵守相同规则。

## 迁移风格

- 采用一比一迁移节奏。
- 目录结构与函数顺序尽量贴近源任务。
- 优先复用目标代码库中已有的 mjlab 原生表达模式。
- 接口差异造成实现形态变化时，优先选择 mjlab 官方 API 的原生写法，而不是保留 IsaacLab 语义壳层。
- 将改动限制在：imports、API 字段名、配置表达方式、注册接线。
