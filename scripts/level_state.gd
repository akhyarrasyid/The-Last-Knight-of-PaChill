extends Node2D

@export var level_id: int

var enemy_count: int
var is_paused = false
var is_start = true

var is_dead = false

@onready var pause_menu_ui: CanvasLayer = %PauseMenu
@onready var hud: CanvasLayer = %HUD

func _ready() -> void:
	MusicPlayer.play_main()
	GameState.set_level(level_id)
	GameState.start_timer()
	pause_menu_ui.hide()
	hud.update_enemies_remaining(enemy_count)

func register_player_death():
	is_dead = true

func register_enemy_spawn():
	is_start = false
	enemy_count += 1
	
func register_enemy_death():
	enemy_count -= 1
	hud.update_enemies_remaining(enemy_count)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause_menu()

func _process(_delta: float) -> void:
	if is_dead:
		GameState.stop_timer()
		get_tree().change_scene_to_file("res://scenes/ui/died_menu.tscn")
	
	if !is_start and is_level_finished():
		GameState.stop_timer()
		get_tree().change_scene_to_file("res://scenes/ui/end_menu.tscn")

func is_level_finished() -> bool:
	return enemy_count == 0

func toggle_pause_menu():
	if is_paused:
		pause_menu_ui.hide()
		Engine.time_scale = 1
		set_physics_process(true)
		set_process(true)
		GameState.unpause_timer()
	else:
		pause_menu_ui.show()
		Engine.time_scale = 0
		set_physics_process(false)
		GameState.stop_timer()
		
	is_paused = !is_paused
