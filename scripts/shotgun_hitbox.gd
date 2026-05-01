extends Area2D

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
	if body is Slime:
		body.hit()
	if body is FireGoblin:
		body.hit()
