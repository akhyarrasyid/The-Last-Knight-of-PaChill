extends CanvasLayer

@onready var dash_bar: ProgressBar = %Dash/DashBar
@onready var shotgun_bar: ProgressBar = %Shotgun/ShotgunBar

func _ready() -> void:
	$HUDContainer.modulate.a = 0
	var tween = create_tween()
	tween.tween_property($HUDContainer, "modulate:a", 1.0, 0.5)
	
	dash_bar.value = 100
	shotgun_bar.value = 100

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
