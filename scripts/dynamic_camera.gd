extends Camera2D

var target_distance = 0
var mouse_position = Vector2.ZERO
var joystick_direction = Vector2.ZERO

@export var SPEED := 120

func _process(delta: float) -> void:
	var direction
	if GameState.kbm_active:
		mouse_position = get_local_mouse_position()
		direction = position.direction_to(mouse_position)
	else:
		direction = joystick_direction
		
	
	var new_position = position + (direction * target_distance * SPEED * delta)
	if new_position.length() < 200:
		position = new_position
	else:
		position = new_position.normalized() * 200

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and GameState.kbm_active:
		var mouse_distance = position.distance_to(mouse_position)
		target_distance = clamp(mouse_distance, 0, 10) * (2.0/3.0)
	elif !GameState.kbm_active:
		joystick_direction = Input.get_vector("look_left", "look_right", "look_up", "look_down")
		target_distance = (joystick_direction.length()) * 10 * (2.0/3.0)
