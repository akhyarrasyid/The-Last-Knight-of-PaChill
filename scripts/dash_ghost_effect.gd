extends Sprite2D

func _ready() -> void:
	ghosting()

func set_position_and_scale(pos, t_scale):
	position = pos
	scale = t_scale
	
func flip(is_flip: bool):
	set_flip_h(is_flip)
	
func ghosting():
	var tween_fade = get_tree().create_tween()
	
	tween_fade.tween_property(self, "self_modulate", Color(1, 1, 1, 0), 0.75)
	await tween_fade.finished
	
	queue_free()
