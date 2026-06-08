extends CanvasLayer

@onready var dash_bar: ProgressBar = %Dash/DashBar
@onready var shotgun_bar: ProgressBar = %Shotgun/ShotgunBar
@onready var objective_arrow: Sprite2D = $ObjectiveArrow

@export var objective_show_distance := 425.0
@export var objective_visibility_margin := 120.0

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
	var player := get_node_or_null("/root/Level/Player") as Node2D
	if player == null:
		objective_arrow.hide_indicator()
		return

	var target := get_nearest_enemy(player)
	if target == null:
		objective_arrow.hide_indicator()
		return

	var direction := target.global_position - player.global_position
	if direction.length() < objective_show_distance and is_enemy_clearly_visible(target):
		objective_arrow.hide_indicator()
		return

	objective_arrow.update_direction(direction, get_viewport().get_visible_rect().size)

func get_nearest_enemy(player: Node2D) -> Node2D:
	var nearest_enemy: Node2D = null
	var nearest_distance := INF

	for container_name in ["FireGoblins", "Slimes"]:
		var container := get_node_or_null("/root/Level/%s" % container_name)
		if container == null:
			continue

		for enemy in container.get_children():
			if not (enemy is Node2D) or enemy.is_queued_for_deletion():
				continue

			var enemy_node := enemy as Node2D
			var distance := player.global_position.distance_to(enemy_node.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_enemy = enemy_node

	return nearest_enemy

func is_enemy_clearly_visible(enemy: Node2D) -> bool:
	var screen_position := enemy.get_global_transform_with_canvas().origin
	var visible_rect := get_viewport().get_visible_rect().grow(-objective_visibility_margin)
	return visible_rect.has_point(screen_position)
