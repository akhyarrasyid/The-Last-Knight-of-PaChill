extends AnimatedSprite2D

func play_idle_animation() -> void:
	if self.is_playing() && self.animation.begins_with("attack"):
		return
	play("idle")

func play_walk_animation() -> void:
	if self.is_playing() && self.animation.begins_with("attack"):
		return
	play("walk")

func play_attack_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		play("attack_horizontal")
	else:
		if direction.y >= 0:
			play("attack_down")
		else:
			play("attack_up")
