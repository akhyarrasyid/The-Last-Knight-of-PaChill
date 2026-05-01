extends CanvasLayer

@onready var menu_content: Control = $MenuContent
@onready var overlay_background: ColorRect = $OverlayBackground

func _ready() -> void:
	# Initial State for Animation
	overlay_background.modulate.a = 0
	menu_content.position.x = get_viewport().get_visible_rect().size.x
	
	# Create Cinematic Animation
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(overlay_background, "modulate:a", 1.0, 0.6)
	tween.tween_property(menu_content, "position:x", 0.0, 0.8)
	
	update_high_scores()

func update_high_scores() -> void:
	var no_score := "High Score: NA"
	
	# Ambil node secara dinamis untuk menghindari instantiation error
	var labels = [
		$MenuContent/MarginContainer/HBoxContainer/VBoxContainer2/Level1HighScore,
		$MenuContent/MarginContainer/HBoxContainer/VBoxContainer2/Level2HighScore,
		$MenuContent/MarginContainer/HBoxContainer/VBoxContainer2/Level3HighScore
	]
	
	for i in range(3):
		var score = GameState.highscore_map[i]
		if score > 0:
			var minutes: int = int(float(score) / 60.0)
			var seconds: int = int(score) % 60
			labels[i].text = "High Score: %02d:%02d" % [minutes, seconds]
		else:
			labels[i].text = no_score

func _on_level_1_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level1.tscn")

func _on_level_2_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level2.tscn")

func _on_level_3_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level3.tscn")
