extends Sprite2D

@export var orbit_radius := 135.0
@export var bob_amount := 8.0
@export var bob_speed := 4.0
@export var rotation_offset := PI

var _bob_time := 0.0
var _base_scale := Vector2.ONE


func _ready() -> void:
	hide()
	centered = true
	_base_scale = scale


func _process(delta: float) -> void:
	if not visible:
		return

	_bob_time += delta
	var pulse := 1.0 + sin(_bob_time * bob_speed) * 0.06
	scale = _base_scale * pulse


func update_direction(direction: Vector2, viewport_size: Vector2) -> void:
	if direction.is_zero_approx():
		hide()
		return

	show()
	var bob_offset := sin(_bob_time * bob_speed) * bob_amount
	position = viewport_size * 0.5 + direction.normalized() * (orbit_radius + bob_offset)
	rotation = direction.angle() + rotation_offset


func hide_indicator() -> void:
	hide()
