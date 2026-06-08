extends CharacterBody2D

class_name FireGoblin

@export var SPEED = 300.0

@export var homing_fire: PackedScene
@export var explosion: PackedScene

@onready var attack_wait_time: Timer = $AttackWaitTime
@onready var anim_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound

@onready var level_state := get_node("/root/Level")

func _ready() -> void:
	shoot_sound.stream = load("res://assets/audio/fire keluar dari badan enemy api.wav")
	shoot_sound.bus = "Master"
	level_state.register_enemy_spawn()

func _physics_process(_delta: float) -> void:
	var player = %Player
	var distance = get_distance_from_player(player)
	var direction = self.global_position.direction_to(player.global_position)
	
	var isAttackingInXAxis = true
	
	if distance > 250.0 and not (anim_sprite.animation.begins_with("attack") and anim_sprite.is_playing()):
		anim_sprite.play_idle_animation()
	elif distance > 125.0 and not (anim_sprite.animation.begins_with("attack") and anim_sprite.is_playing()):
		anim_sprite.play_walk_animation()
		run_toward_player(player)
	elif attack_wait_time.is_stopped():
		isAttackingInXAxis = ( abs(direction.x) > abs(direction.y) )
		anim_sprite.play_attack_animation(direction)
		shoot_fireball(player)
	elif not (anim_sprite.animation.begins_with("attack") and anim_sprite.is_playing()):
		anim_sprite.play_idle_animation()
	
	# flip if direction is left except if attacking up or down
	anim_sprite.set_flip_h(isAttackingInXAxis and direction.x < 0)

func get_distance_from_player(player):
	return global_position.distance_to(player.global_position)

func run_toward_player(player):
	velocity = (player.position - position).normalized() * SPEED
	move_and_slide()
	
func shoot_fireball(player):
	shoot_sound.play()
	attack_wait_time.start(1)
	var fireball = homing_fire.instantiate()
	var fireball_spawn = self.global_position + (player.global_position - self.global_position).normalized()*35
	get_parent().add_child(fireball)
	fireball.start(fireball_spawn, player, self)

func _on_attack_animation_finished() -> void:
	if anim_sprite.animation.begins_with("attack"):
		anim_sprite.play_idle_animation()

func hit() -> void:
	set_physics_process(false)
	var explode = explosion.instantiate()
	explode.position = global_position
	get_parent().add_child(explode)
	explode.play_explode_animation()
	call_deferred("queue_free")
	level_state.register_enemy_death()
