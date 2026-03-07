# mjlab.terrains API Reference

## Sources

- `mjlab/docs/source/api/terrains.rst`
- `mjlab/docs/source/terrain.rst`
- `mjlab/src/mjlab/terrains/__init__.py`

## Public API

### Core

- `TerrainEntity`
- `TerrainEntityCfg`
- `TerrainGenerator`
- `TerrainGeneratorCfg`
- `SubTerrainCfg`
- `FlatPatchSamplingCfg`

### Heightfield

- `HfDiscreteObstaclesTerrainCfg`
- `HfPerlinNoiseTerrainCfg`
- `HfRandomUniformTerrainCfg`
- `HfPyramidSlopedTerrainCfg`
- `HfWaveTerrainCfg`

### Primitive / Box

- `BoxFlatTerrainCfg`
- `BoxInvertedPyramidStairsTerrainCfg`
- `BoxNarrowBeamsTerrainCfg`
- `BoxNestedRingsTerrainCfg`
- `BoxOpenStairsTerrainCfg`
- `BoxPyramidStairsTerrainCfg`
- `BoxRandomGridTerrainCfg`
- `BoxRandomSpreadTerrainCfg`
- `BoxRandomStairsTerrainCfg`
- `BoxSteppingStonesTerrainCfg`
- `BoxTiltedGridTerrainCfg`

## How to use it during migration

- Pure flat ground: `TerrainEntityCfg(terrain_type="plane")`
- Generated terrain: `TerrainEntityCfg(terrain_type="generator", terrain_generator=...)`
- Curriculum terrain for training: `TerrainGeneratorCfg(curriculum=True, num_rows=..., num_cols=...)`

## Key ideas for curriculum terrain

- columns: terrain type
- rows: difficulty level
- `max_init_terrain_level`: initial difficulty cap
- The `terrain_levels_vel` curriculum term raises or lowers difficulty based on episode performance.

## Migration gotchas

- Do not copy IsaacLab's terrain importer / prim system verbatim.
- Rewrite it directly as `TerrainEntityCfg` + `TerrainGeneratorCfg`.
- `TerrainImporter` / `TerrainImporterCfg` are only deprecated aliases inside `mjlab.terrains`.

## Recommended reading

- Scene assembly: `references/mjlab-api-scene.md`
- Curriculum terms: `references/mjlab-api-managers.md`
