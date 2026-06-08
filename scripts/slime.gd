extends CharacterBody2D

class_name Slime

const CombatElevationUtils := preload("res://scripts/combat_elevation.gd")

@export var SPEED = 300.0
@export var explosion: PackedScene
@export var max_attack_vertical_diff := 32.0

@onready var slime_animation: AnimatedSprite2D = $AnimatedSprite2D

@onready var level_state := get_node("/root/Level")
@onready var bomb_sound: AudioStreamPlayer2D = $BombSound

var player = null
var fuse_timer: float = 0.0

func _ready() -> void:
	bomb_sound.stream = load("res://assets/audio/bomb slime.wav")
	bomb_sound.bus = "Master"
	slime_animation.play_spawn_animation()
	level_state.register_enemy_spawn()

func _physics_process(delta: float) -> void:
	if !player:
		slime_animation.play_idle_animation()
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	velocity = (player.global_position - global_position).normalized() * SPEED * delta
	
	# Bomb Sound Logic
	if !bomb_sound.playing:
		bomb_sound.play()
	
	fuse_timer += delta
	var dist = global_position.distance_to(player.global_position)
	
	# Get louder as we get closer (up to 500 units away)
	var vol = lerp(-20.0, 5.0, clamp(1.0 - (dist / 500.0), 0.0, 1.0))
	bomb_sound.volume_db = vol
	
	# Get faster as time runs out (10s fuse)
	var pitch = lerp(1.0, 1.8, clamp(fuse_timer / 10.0, 0.0, 1.0))
	bomb_sound.pitch_scale = pitch
	
	if fuse_timer >= 10.0:
		explode()
		return
	
	if player.is_dashing:
		slime_animation.play_idle_animation()
		move_and_slide()
	elif !player.is_dashing:
		var collision = move_and_collide(velocity)
		if collision:
			velocity = velocity.bounce(collision.get_normal())
			var collider = collision.get_collider()
			if collider is Player and collider.has_method("hit") and CombatElevationUtils.can_hit_target(self, collider, max_attack_vertical_diff):
				collider.hit(velocity)
				explode() # Explosion on hit!
		else:
			slime_animation.play_idle_animation()

func hit() -> void:
	slime_animation.play_damaged_animation()
	set_physics_process(false)
	# queue free on animation finish

func _on_detect_radius_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body

func _on_detect_radius_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null

func _on_slime_animation_finished() -> void:
	if slime_animation.animation == "spawn":
		slime_animation.play_idle_animation()
	if slime_animation.animation == "damaged":
		explode()

func explode() -> void:
	set_physics_process(false)
	bomb_sound.stop()
	
	var explode_node = explosion.instantiate()
	explode_node.position = global_position
	get_parent().add_child(explode_node)
	
	explode_node.play_explode_animation()
	
	level_state.register_enemy_death()
	queue_free()
	
