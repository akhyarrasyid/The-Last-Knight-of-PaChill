extends Area2D

const CombatElevationUtils := preload("res://scripts/combat_elevation.gd")

@export var max_attack_vertical_diff := 32.0

func set_direction(direction: Vector2):
	rotation = direction.angle()

func enable():
	self.monitorable = true
	self.monitoring = true
	$AnimatedSprite2D.show()
	$AnimatedSprite2D.play("default")
	
func disable():
	self.monitorable = false
	self.monitoring = false
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.hide()

func _on_body_entered(body: Node2D) -> void:
	var attacker := get_parent() as Node2D
	if body is Slime and CombatElevationUtils.can_hit_target(attacker, body, max_attack_vertical_diff):
		body.hit()
	if body is FireGoblin and CombatElevationUtils.can_hit_target(attacker, body, max_attack_vertical_diff):
		body.hit()
