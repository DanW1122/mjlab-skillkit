# mjlab.viewer API Reference

## Sources

- `mjlab/docs/source/api/viewer.rst`
- `mjlab/docs/source/viewers.rst`
- `mjlab/src/mjlab/viewer/__init__.py`

## Public API

- `ViewerConfig`
- `BaseViewer`
- `NativeMujocoViewer`
- `ViserPlayViewer`
- `OffscreenRenderer`
- `EnvProtocol`
- `PolicyProtocol`
- `VerbosityLevel`

## How to use it during migration

- This is usually not the main migration path, but it is often used for play / debugging / scene export.
- `ViewerConfig` lives on `ManagerBasedRlEnvCfg.viewer`.

## Common viewer choices

- Local desktop debugging: `NativeMujocoViewer`
- Headless or browser interaction: `ViserPlayViewer`
- Screenshots / video / offscreen rendering: `OffscreenRenderer`

## Common `ViewerConfig` fields

- `lookat`
- `distance`
- `elevation`
- `azimuth`
- `origin_type`
- `entity_name`
- `body_name`
- `width`
- `height`

## Migration suggestions

- Viewer configuration only serves debugging and visualization. Do not mix it into MDP logic.
- If the old project has Isaac Sim UI / viewer code, do not migrate it by default. Keep only mjlab viewer capabilities.
