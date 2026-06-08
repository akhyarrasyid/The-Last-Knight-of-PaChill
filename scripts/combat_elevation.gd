extends RefCounted

class_name CombatElevation

const ENVIRONMENT_MASK := 1
const FOOT_SAMPLE_INSET := 6.0


static func can_hit_target(attacker: Node2D, target: Node2D, max_attack_vertical_diff: float = 32.0) -> bool:
	if not is_instance_valid(attacker) or not is_instance_valid(target):
		return false

	var attacker_foot := get_foot_position(attacker)
	var target_foot := get_foot_position(target)

	# Prevent attacks from reaching targets on different elevations when terrain blocks the path.
	if is_environment_blocking(attacker, target, attacker_foot, target_foot):
		return false

	return abs(attacker_foot.y - target_foot.y) <= max_attack_vertical_diff


static func get_foot_position(node: Node2D) -> Vector2:
	var collision_shape := node.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null or collision_shape.shape == null:
		return node.global_position

	var local_bottom := collision_shape.position
	if collision_shape.shape is CircleShape2D:
		var circle := collision_shape.shape as CircleShape2D
		local_bottom.y += circle.radius - FOOT_SAMPLE_INSET
	elif collision_shape.shape is RectangleShape2D:
		var rectangle := collision_shape.shape as RectangleShape2D
		local_bottom.y += rectangle.size.y * 0.5 - FOOT_SAMPLE_INSET
	elif collision_shape.shape is CapsuleShape2D:
		var capsule := collision_shape.shape as CapsuleShape2D
		local_bottom.y += capsule.height * 0.5 + capsule.radius - FOOT_SAMPLE_INSET

	return collision_shape.to_global(local_bottom)


static func is_environment_blocking(attacker: Node2D, target: Node2D, attacker_foot: Vector2, target_foot: Vector2) -> bool:
	var space_state := attacker.get_world_2d().direct_space_state
	var exclude: Array = [attacker, target]
	var samples := [
		[attacker_foot, target_foot],
		[attacker.global_position, target.global_position],
		[attacker_foot + Vector2.UP * 12.0, target_foot + Vector2.UP * 12.0],
	]

	for sample in samples:
		var query := PhysicsRayQueryParameters2D.create(sample[0], sample[1], ENVIRONMENT_MASK, exclude)
		query.collide_with_areas = false
		query.collide_with_bodies = true
		var hit := space_state.intersect_ray(query)
		if not hit.is_empty():
			return true

	return false
