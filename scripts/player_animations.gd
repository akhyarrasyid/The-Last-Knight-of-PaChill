extends AnimatedSprite2D


func play_idle_animation() -> void:
	if self.is_playing() && self.animation.begins_with("attack"):
		return
	play("idle")

func play_walk_animation() -> void:
	if self.is_playing() && self.animation.begins_with("attack"):
		return
	play("walk")

func play_attack_animation(direction: Vector2, is_start_combo: bool) -> void:
	var suffix = "_combo_" + ( "1" if is_start_combo else "2" )
	if abs(direction.x) > abs(direction.y):
		play("attack_left_right" + suffix)
	else:
		if direction.y >= 0:
			play("attack_down" + suffix)
		else:
			play("attack_up" + suffix)

func play_shotgun_animation() -> void:
	play("attack_shotgun")
