extends Area2D

class_name HomingFire

const CombatElevationUtils := preload("res://scripts/combat_elevation.gd")


@export var Explosion: PackedScene
@export var max_attack_vertical_diff := 32.0

@export var speed = 200

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO

@export var steer_force = 20.0
var target = null
var source_attacker: Node2D = null

func start(_position, _target, _source_attacker = null):
	target = _target
	source_attacker = _source_attacker
	global_position = _position
	velocity = (target.position - position).normalized() * speed

func seek():
	var steer = Vector2.ZERO
	if target:
		var desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	return steer

func _physics_process(delta):
	acceleration += seek()
	velocity += acceleration * delta
	velocity.x = clamp(velocity.x, -150, 150)
	velocity.y = clamp(velocity.y, -150, 150)
	#rotation = velocity.angle()
	position += velocity * delta


func _on_body_entered(body: Node2D) -> void:
	if body is Player and CombatElevationUtils.can_hit_target(source_attacker if source_attacker else self, body, max_attack_vertical_diff):
		body.hit(velocity)
	trigger_explosion()
		
func _on_area_entered(area: Area2D) -> void:
	if area is Shield:
		trigger_explosion()
	

func trigger_explosion():
	var explosion = Explosion.instantiate()
	get_parent().add_child(explosion)
	explosion.global_transform = self.global_transform
	explosion.play_explode_animation()
	queue_free()


func _on_lifetime_timeout() -> void:
	queue_free()
