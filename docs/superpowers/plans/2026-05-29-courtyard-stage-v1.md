# Courtyard Stage V1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the courtyard from blockout rectangles into a reference-driven, layered side-scrolling stage while preserving existing gameplay entry points.

**Architecture:** Add a `CourtyardStageBuilder` that mirrors the indoor stage-builder pattern: it hides legacy placeholder visuals and generates named visual layers from a deterministic spec. `main.gd` owns gameplay nodes, spawn points, collisions, and camera config; the builder owns only visual composition.

**Tech Stack:** Godot 4.6.2, GDScript, GdUnit4, procedural `Polygon2D` / `Line2D` / `ColorRect` stage placeholders.

---

### Task 1: Regression Test

**Files:**
- Create: `tests/unit/courtyard_stage_builder_test.gd`

- [ ] **Step 1: Write failing tests**
  - Assert the builder script exists.
  - Assert generated courtyard nodes include `CourtyardMainHouse`, `CourtyardOldHouse`, `CourtyardWell`, `CourtyardClothesline`, and `CourtyardForegroundShade`.
  - Assert legacy `ColorRect` placeholders are hidden after rebuild.

- [ ] **Step 2: Run test**
  - Command: `addons\gdUnit4\runtest.cmd --godot_binary .local_tools\Godot\Godot_console.exe --ignoreHeadlessMode --add tests\unit\courtyard_stage_builder_test.gd`
  - Expected before implementation: parse/load failure or missing builder failure.

### Task 2: Builder

**Files:**
- Create: `scripts/scenes/courtyard_stage_builder.gd`

- [ ] **Step 1: Implement deterministic visual generation**
  - Provide `rebuild(parent, spec)` and helper methods for rectangles, lines, ellipses, and polygons.
  - Add all generated nodes to group `generated_courtyard_stage`.
  - Hide legacy placeholder `ColorRect` / `Polygon2D` nodes without disabling triggers, NPCs, or the player.

- [ ] **Step 2: Verify test passes**
  - Command: same as Task 1.
  - Expected: all courtyard builder tests pass.

### Task 3: Main Scene Runtime Hook

**Files:**
- Modify: `scripts/main.gd`

- [ ] **Step 1: Call the builder before common setup**
  - Add `_rebuild_courtyard_stage()` in `_ready()`.
  - Reposition `House` so the existing `HouseDoor` trigger aligns with the new main building doorway.
  - Keep gameplay nodes and scene switching unchanged.

- [ ] **Step 2: Adjust collision helper bodies**
  - Update `_add_depth_collisions()` body dimensions to match the new visual composition.
  - Keep player movement bounds in `SceneManager` unchanged for this pass.

### Task 4: Handoff And Verification

**Files:**
- Modify: `docs_dev/architecture_handoff.md`

- [ ] **Step 1: Document the courtyard visual method**
  - Explain that courtyard visuals now use `CourtyardStageBuilder`.
  - Record the reference-composition rules for future Claude Code / DeepSeek work.

- [ ] **Step 2: Run full unit tests**
  - Command: `addons\gdUnit4\runtest.cmd --godot_binary .local_tools\Godot\Godot_console.exe --ignoreHeadlessMode --add tests\unit`
  - Expected: all unit tests pass.
