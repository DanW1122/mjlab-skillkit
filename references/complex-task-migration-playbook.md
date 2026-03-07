# General Playbook for Complex Task Migration

This playbook is the **general migration methodology for AI**, not instructions specific to a single task.

Applicable to:

- tracking
- imitation / motion imitation
- whole-body control
- locomotion/manipulation tasks with many variants
- any task that simultaneously contains `train / play / eval / no-state-estimation / low-freq / robot-specific` branches

If a case-specific document is very detailed (for example `references/tracking-case-study.md`), treat it as an **example**; the default workflow should still start with this file first.

---

## 1) First decide: is this a “complex task”?

If any one of the following is true, treat it as a complex task:

- the source has multiple env-cfg inheritance variants
- the source simultaneously has env cfg, RL cfg, registry, and play/eval scripts
- the target side already has tests / registry for the same task family
- randomization semantics are split across command / event / sensor / runner cfg
- besides the main task, there are derived modes such as no-state-estimation / low-freq / play / special robot

**Principles:**

- For complex tasks, do not start by changing imports
- Align structure first, then rewrite APIs

---

## 2) Draw the four-layer structure first

For a complex task, split it into four layers first:

1. **base task env**
   - task-level shared scene / managers / sim / viewer
2. **variant layer**
   - robot-specific
   - state-estimation on/off
   - terrain / morphology / sensing differences
3. **RL cfg layer**
   - PPO/RSL-RL hyperparameters
   - actor/critic models
   - low-freq / play / special-runner adjustments
4. **registration / play entry layer**
   - task id
   - `play_env_cfg`
   - runner class
   - CLI/registry wiring

If these four layers are not separated clearly, later field mapping easily turns into “it runs, but the semantics are misplaced”.

---

## 3) Build a variant matrix first

Before any complex-task migration, AI should first write a **variant matrix**:

| Semantic variant | Source landing point | Target landing point | Status |
| --- | --- | --- | --- |
| base training | env cfg / register | env cfg / task id | aligned / pending |
| play / eval | play script / cfg override | `play_env_cfg` / play flag | aligned / pending |
| no-state-estimation | subclass / config term removal | independent task / factory parameter | aligned / pending |
| low-freq | env cfg + rl cfg | independent task / runner variant / unimplemented | aligned / pending |
| robot-specific | robot cfg override | robot-specific env factory | aligned / pending |

You must answer three questions:

- Where does each source variant land in the target?
- Is it an independent task, a function parameter, or part of `play_env_cfg`?
- If it does not exist in the target, is that intentional or an omission?

---

## 4) Read target registry and tests first

For complex tasks, these target-side files have very high priority:

- task package `__init__.py`
- same-family `tests/`
- `rl_cfg.py`
- nearby example tasks

They tell you:

- **registry**: which entry points exist, which are task ids, and which are play branches
- **tests**: which behaviors the target repository considers mandatory
- **rl cfg**: which differences live in training config rather than env config

**Rules:**

- tests are not “supplementary material”; they are migration contracts
- registry is not “wiring detail”; it defines the variant structure

---

## 5) Let the “central object” decide migration order

Do not always migrate complex tasks in file order.

Instead, first identify the **central object**:

- tracking/imitation often centers on `command`
- command-conditioned locomotion often centers on `commands`
- manipulation often centers on `scene entity + command + reward contact logic`

General order:

1. central object (usually command / task core runtime)
2. observations
3. rewards / terminations
4. events / randomization / sensors
5. robot-specific overrides
6. rl cfg
7. registry / play / eval entry

Why:

- observations / rewards / done logic often depend on the semantics of the central object
- if the central object is not aligned, later migration may look clean but only align surface form

---

## 6) Treat randomization as “responsibility allocation”, not field renaming

In complex tasks, source randomization/perturbation may be distributed across:

- event
- command resample
- sensor bias
- action bias
- rl runner / play override

So do not make these mistakes:

- seeing one event in the source and insisting the target must also expose an event with the same name
- seeing no explicit play cfg in the source and assuming the target also needs no separate play handling

Correct process:

1. First ask “what is ultimately being perturbed?”
2. Then ask “when does it take effect?”
3. Then ask “what is the most natural landing point in the target?”

Possible target landing points:

- `events[...]`
- `commands[...]`
- sensor config
- action config
- `play_env_cfg`
- rl cfg

---

## 7) Do not migrate only env cfg

The most common mistake in complex tasks is migrating only `env_cfg` while missing:

- `rl_cfg`
- `register_mjlab_task(...)`
- `play_env_cfg`
- target-test constraints
- number of registered variants

You must verify together:

- training entry
- play entry
- number of variants
- variant semantics

---

## 8) Minimal Acceptance Template for Complex Tasks

Before calling a migration complete, confirm at minimum:

- the base variant is aligned
- play/eval semantics are aligned
- special variants were not silently dropped
- the key central object has the correct type
- key assertions in target tests still hold
- important source hyperparameters were not migrated only in env cfg while being missed in rl cfg

If the target has tests, turn their assertions into your acceptance checklist.

---

## 9) Relationship to Case Documents

- `references/complex-task-migration-playbook.md`
  - provides the **general methodology**
- `references/tracking-case-study.md`
  - provides the **specific example of `whole_body_tracking -> mjlab.tasks.tracking`**

Recommended order of use:

1. read this file first
2. then read the closest concrete case
3. only then start editing code
