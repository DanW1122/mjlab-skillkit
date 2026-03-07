# mjlab Mesh Import Guidelines

This file guides the AI through common issues when bringing **STL / OBJ / other mesh assets** into `mjlab`.

It is a general rule set that applies to:

- creating new mjlab robot / object assets
- migrating mesh assets from IsaacLab / USD / URDF / MJCF
- adding mesh entities such as tables, tools, manipulable objects, or obstacles to a task

---

## One-sentence rule

- A **visual mesh** can be used directly as a visual asset.
- A **collision mesh** should not be used directly as a single collision geom if it is non-convex. Perform **convex decomposition** first, or rewrite it as multiple primitive / convex collision geoms.

---

## Why this matters

In MuJoCo, **rendering** and **collision** for meshes are different concerns:

- rendering can preserve the original non-convex appearance
- collision is treated as **convex** by default

If a non-convex object is imported as one raw STL / OBJ collision geom, it usually causes:

- contact shapes that do not match the visible appearance
- unstable physical behavior
- unexpected contact points / normals / friction behavior
- semantic mismatch for domain randomization, contact rewards, and contact sensors

Therefore, **if a mesh participates in collision, you should explicitly design its collision representation**.

---

## Default decision order for the AI

### 1) Ask first: what is this mesh used for?

- visual display only
- visual display and collision
- collision only, with no visual role

### 2) If it participates in collision, use this priority order

1. **Prefer primitive collision geoms**
   - sphere
   - capsule
   - box
   - cylinder / other native convex MuJoCo geoms
2. **Then multiple simple convex geoms as an approximation**
3. **Then convex mesh pieces produced by external convex decomposition**

Do not treat a “raw non-convex STL” as a complete collision solution by default.

---

## Recommended asset pattern in mjlab

Existing `mjlab` assets are much closer to this pattern:

- visual: keep the mesh appearance
- collision: define box / capsule / sphere / multi-part convex geoms separately

This is very clear in the current asset zoo:

- `mjlab/src/mjlab/asset_zoo/robots/unitree_go1/xmls/go1.xml`
- `mjlab/src/mjlab/asset_zoo/robots/unitree_g1/xmls/g1.xml`

These asset files commonly use:

- `<geom class="visual" mesh="..."/>` for visible shape
- `<geom class="collision" type="box|capsule|sphere" .../>` or similar multi-part collision geoms for the contact model

**Conclusion:**

- In mjlab, the common best practice is not “one mesh handles both visuals and collision”
- It is “visual and collision modeling are kept separate”

---

## Extra care when migrating from IsaacLab / USD / other formats

Common situations in source projects:

- visual meshes and collision representations are hidden by the importer or the physics engine
- PhysX / USD may already include a collision approximation that is not preserved automatically during migration

When moving into mjlab, the AI must not assume those collision representations still exist automatically.

You must verify explicitly:

1. whether the source mesh is visual-only
2. whether the source collision has already been convex-decomposed
3. which collision geoms the source contact / reward / sensor logic depends on
4. whether the target needs geom renaming so that:
   - contact sensors
   - friction randomization
   - rewards / penalties
   - terminations
   still match the correct geoms

---

## Practical advice

### Case A: tables, boxes, obstacles

- If the shape is simple, use box / capsule / cylinder collisions directly
- If the visual is complex, keep the visual mesh and approximate collision with a small set of primitives

### Case B: hands, feet, end-effectors, tool tips

- These usually affect contact rewards / terminations / friction randomization directly
- Prefer stable, named collision geoms that can be matched via regex
- Do not attach a complex non-convex mesh as an opaque collision body

### Case C: manipulable objects (`mug`, `bottle`, `handle`, `tool`)

- If grasping / contact behavior matters, prefer convex decomposition or explicit multi-part convex collision
- Also ensure geom names can be referenced precisely by rewards / sensors / events

---

## Hard rules for the AI

- Do not assume raw STL / OBJ files are safe to use directly as non-convex collision bodies
- If a mesh participates in collision, distinguish first between:
  - visual mesh
  - collision representation
- If no collision representation already exists, recommend by default:
  - primitive approximation
  - or multiple convex parts after external convex decomposition
- If the task depends on contact rewards / friction randomization / contact sensors:
  - the collision-geom naming design must be completed together with the collision model

---

## Recommended reading

- Authoring workflow: `references/mjlab-authoring-workflow.md`
- Entity API: `references/mjlab-api-entity.md`
- General complex-task migration: `references/complex-task-migration-playbook.md`

## References

- MuJoCo official collision notes (mesh collision is treated as convex, and non-convex objects should be decomposed into convex geoms):
  - `https://mujoco.readthedocs.io/en/stable/computation/`
- Local `mjlab` asset examples:
  - `mjlab/src/mjlab/asset_zoo/robots/unitree_go1/xmls/go1.xml`
  - `mjlab/src/mjlab/asset_zoo/robots/unitree_g1/xmls/g1.xml`
