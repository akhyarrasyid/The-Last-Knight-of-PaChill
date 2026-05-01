extends AnimatedSprite2D


func play_spawn_animation() -> void:
	if self.is_playing() and self.animation.begins_with("damaged"):
		return
	play("spawn")

func play_idle_animation() -> void:
	if self.is_playing() and (self.animation == "damaged" or self.animation == "spawn"):
		return
	play("idle")

func play_damaged_animation() -> void:
	play("damaged")
