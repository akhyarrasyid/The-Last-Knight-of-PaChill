# Godot MCP — Skills for AI Assistants

> Copy this file to `.claude/skills.md` (or equivalent for your AI client) in your Godot project root.

## What is Godot MCP?

You have access to MCP tools that connect directly to the Godot 4 editor via WebSocket on port 6505. You can browse files, create and modify scenes, write GDScript, inspect the scene tree, run the game, and generate SVG-based sprites — all without the user leaving this conversation.

**Important:** This is the free, open-source version (`godot-mcp-server` on npm). It does NOT have undo/redo integration — all changes save directly. Always recommend the user use version control (git).

---

## Essential Workflows

### 1. Explore a Project First

Always understand the project before making changes:

```
get_project_info        → project name, Godot version, main scene, viewport size
list_directory          → browse folders (start from "res://")
read_file               → read any .gd, .tscn, .tres, .cfg file
get_scene_tree          → node hierarchy of the currently open scene
get_project_settings    → check project.godot configuration
search_files            → find files by name or extension pattern
```

### 2. Build a 2D Scene

```
create_scene     → create .tscn file with a root node type
add_node         → add child nodes with initial properties
set_node_property → set position, scale, texture, modulate, etc.
attach_script    → attach a .gd file to a node
create_script    → write a new GDScript file
save_scene       → save scene to disk
```

**Example — creating a player:**
1. `create_scene` root_type `CharacterBody2D`, path `res://scenes/player.tscn`
2. `add_node` type `Sprite2D`, parent path `/root`
3. `set_node_property` to assign texture path
4. `add_node` type `CollisionShape2D`
5. `assign_collision_shape` to define the shape (RectangleShape2D, CapsuleShape2D, etc.)
6. `create_script` with movement logic
7. `attach_script` to the root node
8. `save_scene`

### 3. Write & Edit Scripts

```
create_script    → create a new .gd file (provide full content)
edit_script      → modify an existing script
  - Use `replacements: [{search: "old code", replace: "new code"}]` for surgical edits
  - Use `content` for full file replacement
read_file        → always read first before editing
validate_script  → check for syntax errors without running
rename_file      → rename a script and update references
```

### 4. Playtest & Debug

```
play_scene           → launch the game ("current" scene or a specific path)
stop_scene           → stop the running game
get_editor_errors    → check for script errors and runtime exceptions
get_output_log       → read print() output and warnings
get_game_screenshot  → capture what the game looks like right now
```

**Basic playtesting loop:**
1. `play_scene` → start the game
2. `get_game_screenshot` → see current state
3. `get_editor_errors` → check for issues
4. `stop_scene` → stop
5. Fix scripts → repeat

### 5. Project Configuration

```
get_project_settings   → read current settings
set_project_setting    → change viewport size, physics, rendering, etc.
get_input_map          → read existing input actions
set_input_action       → define controls (move_left → KEY_A, jump → KEY_SPACE, etc.)
get_collision_layers   → read layer names
```

**Never edit `project.godot` directly** — Godot overwrites it. Always use `set_project_setting`.

### 6. Asset Generation

```
generate_sprite   → generate a 2D sprite from SVG markup
                    (use for simple geometric shapes, icons, placeholder art)
map_project       → launch interactive browser-based project visualizer at localhost:6510
```

**`generate_sprite` tips:**
- Best for: geometric shapes, simple icons, UI elements, placeholder sprites
- Not suitable for: photorealistic art, complex illustrations
- SVG is converted and saved as a `.png` resource

### 7. Interactive Visualizer

Run `map_project` to open a browser at `localhost:6510` with:
- Force-directed graph of all scripts and their relationships
- Click any script to see variables, functions, signals, and connections
- Scene view with node property inspection
- Edit code directly — changes sync to Godot in real time

Use this when you need to understand how a complex project is wired together before making changes.

---

## Property Value Formats

Properties are parsed from strings. Use these formats:

| Type | Format |
|------|--------|
| Vector2 | `"Vector2(100, 200)"` |
| Vector3 | `"Vector3(1, 2, 3)"` |
| Color | `"Color(1, 0, 0, 1)"` or `"#ff0000"` |
| Bool | `"true"` / `"false"` |
| Number | `"42"` / `"3.14"` |
| Enum | Integer value, e.g. `"0"` |
| NodePath | `"../OtherNode"` |

---

## GDScript Best Practices

### Type annotations in loops
```gdscript
# BAD — type inference can fail on untyped arrays
for item in some_array:
    var x := item.value

# GOOD
for i in range(some_array.size()):
    var item: Dictionary = some_array[i]
    var x: int = item.value
```

### Signal connections
Connect signals in `_ready()` using the modern syntax:
```gdscript
func _ready() -> void:
    button.pressed.connect(_on_button_pressed)
```

### Autoloads / Singletons
Add autoloads via `set_project_setting` or through the editor. Reference them directly by name in scripts (e.g. `GameState.score`).

---

## Known Limitations

| Feature | Status |
|---------|--------|
| Undo/Redo | ❌ Not supported — use git |
| Physics setup tools | ❌ Manual via script/inspector |
| Audio bus management | ❌ Manual |
| Shader tools | ❌ Manual |
| Particle presets | ❌ Manual |
| AnimationTree | ❌ Manual |
| TileMap tools | ❌ Manual |
| Runtime node inspection | ⚠️ Limited (screenshot + errors only) |
| Remote deployment | ❌ Not supported |

For these features, either write the GDScript manually or recommend the user set them up directly in the Godot editor.

---

## Recommended Build Order (New Project)

1. **Explore** — `get_project_info`, `list_directory`, understand existing structure
2. **Project settings** — `set_project_setting` for viewport size, physics layers
3. **Input map** — `set_input_action` for all player controls
4. **Main scene** — `create_scene`, set as main scene in project settings
5. **Player scene** — sprite, collision, movement script
6. **World/Level** — environment, platforms, obstacles
7. **Game logic** — enemies, items, pickups via scripts
8. **UI/HUD** — Control nodes, labels, health bars
9. **Playtest** — `play_scene`, `get_editor_errors`, `get_game_screenshot`
10. **Polish** — particles, animations, audio (do manually in editor)

---

## Debugging Checklist

When something doesn't work:

```
get_editor_errors    → runtime exceptions and script errors
get_output_log       → print() statements and warnings
read_file            → re-read the script to see current state
get_scene_tree       → verify node structure is correct
get_game_screenshot  → see the game visually while running
```

Common issues:
- **Node not found**: check paths with `get_scene_tree` before using `$NodePath`
- **Script not updating**: `edit_script` with full `content` replacement, then re-open scene
- **Collision not working**: verify CollisionShape2D/3D has a shape assigned and is not disabled
- **Scene not saving**: always call `save_scene` after making changes
