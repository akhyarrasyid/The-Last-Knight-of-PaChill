extends CanvasLayer

@onready var dash_bar: ProgressBar = %Dash/DashBar
@onready var shotgun_bar: ProgressBar = %Shotgun/ShotgunBar
@onready var objective_arrow: Sprite2D = $ObjectiveArrow

@export var objective_show_distance := 425.0
@export var objective_visibility_margin := 120.0
@export var upper_platform_tolerance := 128.0

const LEVEL_ROOT_PATH := "/root/Level"
const ENEMY_CONTAINERS := ["FireGoblins", "Slimes"]
const WAYPOINTS_PATH := "ObjectiveWaypoints"
const RAMP_MARKER_NAME := "RampToUpperPlatform"
const UPPER_MARKER_NAME := "UpperPlatformAnchor"

func _ready() -> void:
	$HUDContainer.modulate.a = 0
	var tween = create_tween()
	tween.tween_property($HUDContainer, "modulate:a", 1.0, 0.5)
	
	dash_bar.value = 100
	shotgun_bar.value = 100

func _process(_delta: float) -> void:
	update_objective_arrow()

func update_time_elapsed(time: float):
	var minutes = int(time / 60.0)
	var seconds = int(time) % 60
	%TimeElapsed.text = "Time: %02d:%02d" % [minutes, seconds]
	
func update_enemies_remaining(count: int):
	%EnemiesRemaining.text = "Enemies: %d" % count
	var tween = create_tween()
	tween.tween_property(%EnemyPanel, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(%EnemyPanel, "scale", Vector2(1.0, 1.0), 0.1)

func set_dash_on_cooldown():
	%Dash.add_theme_color_override("font_color", Color.GRAY)

func set_dash_ready():
	%Dash.add_theme_color_override("font_color", Color.GOLD)
	dash_bar.value = 100

func update_dash_progress(progress: float):
	dash_bar.value = progress

func set_shotgun_on_cooldown():
	%Shotgun.add_theme_color_override("font_color", Color.GRAY)

func set_shotgun_ready():
	%Shotgun.add_theme_color_override("font_color", Color.GOLD)
	shotgun_bar.value = 100

func update_shotgun_progress(progress: float):
	shotgun_bar.value = progress

func _on_hud_update_timer_timeout() -> void:
	update_time_elapsed(GameState.timer)

func update_objective_arrow() -> void:
	var player := get_node_or_null("%s/Player" % LEVEL_ROOT_PATH) as Node2D
	if player == null:
		objective_arrow.hide_indicator()
		return

	var enemies := get_live_enemies()
	if enemies.is_empty():
		objective_arrow.hide_indicator()
		return

	var target_data := resolve_objective_target(player, enemies)
	var target := target_data.get("node") as Node2D
	var target_kind := str(target_data.get("kind", "enemy"))
	if target == null:
		objective_arrow.hide_indicator()
		return

	if target_kind == "enemy" and should_hide_enemy_indicator(player, target):
		objective_arrow.hide_indicator()
		return

	var direction := target.global_position - player.global_position
	objective_arrow.update_direction(direction, get_viewport().get_visible_rect().size)

func resolve_objective_target(player: Node2D, enemies: Array[Node2D]) -> Dictionary:
	var ramp_marker := get_objective_waypoint(RAMP_MARKER_NAME)
	var upper_anchor := get_objective_waypoint(UPPER_MARKER_NAME)
	var upper_enemies: Array[Node2D] = []
	var lower_enemies: Array[Node2D] = []

	for enemy in enemies:
		if is_upper_platform_target(enemy, upper_anchor, ramp_marker):
			upper_enemies.append(enemy)
		else:
			lower_enemies.append(enemy)

	if not upper_enemies.is_empty():
		# Elevated enemies route through the ramp first while the player is still below.
		if is_upper_platform_target(player, upper_anchor, ramp_marker):
			return {"node": get_nearest_target(player, upper_enemies), "kind": "enemy"}

		if lower_enemies.is_empty() and ramp_marker != null:
			return {"node": ramp_marker, "kind": "ramp"}

		if not lower_enemies.is_empty():
			return {"node": get_nearest_target(player, lower_enemies), "kind": "enemy"}

		return {"node": get_nearest_target(player, upper_enemies), "kind": "enemy"}

	return {"node": get_nearest_target(player, enemies), "kind": "enemy"}

func get_live_enemies() -> Array[Node2D]:
	var enemies: Array[Node2D] = []

	for container_name in ENEMY_CONTAINERS:
		var container := get_node_or_null("%s/%s" % [LEVEL_ROOT_PATH, container_name])
		if container == null:
			continue

		for enemy in container.get_children():
			if not (enemy is Node2D) or enemy.is_queued_for_deletion():
				continue

			enemies.append(enemy as Node2D)

	return enemies

func get_nearest_target(player: Node2D, candidates: Array[Node2D]) -> Node2D:
	var nearest_target: Node2D = null
	var nearest_distance := INF

	for candidate in candidates:
		var distance := player.global_position.distance_to(candidate.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_target = candidate

	return nearest_target

func get_objective_waypoint(node_name: String) -> Node2D:
	return get_node_or_null("%s/%s/%s" % [LEVEL_ROOT_PATH, WAYPOINTS_PATH, node_name]) as Node2D

func is_upper_platform_target(target: Node2D, upper_anchor: Node2D, ramp_marker: Node2D) -> bool:
	if upper_anchor != null:
		return target.global_position.y <= upper_anchor.global_position.y + upper_platform_tolerance

	if ramp_marker != null:
		return target.global_position.y <= ramp_marker.global_position.y - upper_platform_tolerance

	return false

func should_hide_enemy_indicator(player: Node2D, target: Node2D) -> bool:
	var distance := player.global_position.distance_to(target.global_position)
	return distance < objective_show_distance and is_target_clearly_visible(target)

func is_target_clearly_visible(target: Node2D) -> bool:
	var screen_position := target.get_global_transform_with_canvas().origin
	var visible_rect := get_viewport().get_visible_rect().grow(-objective_visibility_margin)
	return visible_rect.has_point(screen_position)
