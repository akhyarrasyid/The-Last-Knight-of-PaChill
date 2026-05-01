extends CharacterBody2D

class_name Player

@export var SPEED = 200.0
var speed_multiplier = 1.0

@onready var health_bar: ProgressBar = $HealthBar
@onready var cursor: Sprite2D = $Cursor
@onready var hit_invincibility: Timer = $HitInvincibility
@onready var ghost_timer = $GhostEffectTimer
@onready var dash_timer = $DashTimer
@onready var dash_hitbox = $DashHitbox
@onready var shotgun_recoil_timer: Timer = $ShotgunRecoilTimer
@onready var sword_sound: AudioStreamPlayer2D = $WeaponSounds/SwordSound
@onready var shotgun_sound: AudioStreamPlayer2D = $WeaponSounds/ShotgunSound
@onready var dash_sound: AudioStreamPlayer2D = $WeaponSounds/DashSound
@onready var burn_timer: Timer = $BurnTimer

var is_knocked: bool = false # also invincible
var is_dashing: bool = false
var is_shooting: bool = false

var mouse_pos: Vector2

var move_direction: Vector2
var attack_direction: Vector2
var dash_direction: Vector2
var knockback_direction: Vector2
var shotgun_recoil_direction: Vector2

# Attack animation queue
var anim_queue: Array = []
@onready var anim_sprite := %AnimatedSprite2D

@onready var slash_hitbox := %SlashHitbox
@onready var shotgun_hitbox := %ShotgunHitbox
@export var dash_ghost_effect: PackedScene

@onready var level_state := get_node("/root/Level")

func _ready() -> void:
	slash_hitbox.disable()
	shotgun_hitbox.disable()
	
	sword_sound.stream = load("res://assets/audio/sword.wav")
	sword_sound.bus = "Master"
	
	shotgun_sound.stream = load("res://assets/audio/shotgun.wav")
	shotgun_sound.bus = "Master"
	
	dash_sound.stream = load("res://assets/audio/player dash.mp3")
	dash_sound.bus = "Master"
	
	burn_timer.timeout.connect(_on_burn_timeout)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("attack"):
		# half player speed while shooting
		speed_multiplier = 0.5
		
		if anim_sprite.animation.begins_with("attack") and anim_sprite.is_playing():
			if len(anim_queue) >= 2:
				return
			# combo start playing or end
			if anim_sprite.animation.ends_with("1"):
				anim_queue.push_back(false)
			elif anim_sprite.animation.ends_with("2"):
				anim_queue.push_back(true)
			return
		
		anim_sprite.play_attack_animation(attack_direction, true)
		sword_sound.play()
		slash(attack_direction)
	
	elif Input.is_action_just_pressed("dash") and %DashCooldownTimer.is_stopped():
		dash()
	elif Input.is_action_just_pressed("shotgun") and %ShotgunCooldownTimer.is_stopped():
		anim_sprite.play_shotgun_animation()
		shoot_shotgun()

func _physics_process(_delta: float) -> void:
	mouse_pos = get_global_mouse_position()
	
	move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if is_knocked:
		velocity = knockback_direction * SPEED * speed_multiplier
	if is_shooting:
		velocity = shotgun_recoil_direction * SPEED * speed_multiplier
	elif is_dashing:
		velocity = dash_direction * SPEED * speed_multiplier
	else:
		velocity = move_direction * SPEED * speed_multiplier
	
	move_cursor()
	handle_animation()
	
	if not %DashCooldownTimer.is_stopped():
		var progress = (1.0 - (%DashCooldownTimer.time_left / %DashCooldownTimer.wait_time)) * 100
		level_state.hud.update_dash_progress(progress)
	
	if not %ShotgunCooldownTimer.is_stopped():
		var progress = (1.0 - (%ShotgunCooldownTimer.time_left / %ShotgunCooldownTimer.wait_time)) * 100
		level_state.hud.update_shotgun_progress(progress)
	
	move_and_slide()

func handle_animation():
	var isAttackingInYAxis: bool = false
	
	if anim_sprite.animation == &"attack_shotgun":
		if anim_sprite.frame == 2:
			speed_multiplier = 2.5
			shotgun_recoil_direction = attack_direction*-1
			shotgun_recoil_timer.start()
			shotgun_hitbox.disable()
	
	if anim_sprite.animation.begins_with("attack") and anim_sprite.is_playing():
		isAttackingInYAxis = !( abs(attack_direction.x) > abs(attack_direction.y) )
	elif velocity.is_zero_approx():
		anim_sprite.play_idle_animation()
	else:
		anim_sprite.play_walk_animation()
	
	if GameState.kbm_active:
		anim_sprite.set_flip_h(!isAttackingInYAxis and mouse_pos.x < self.global_position.x)
	else:
		anim_sprite.set_flip_h(!isAttackingInYAxis and attack_direction.x < 0)

func move_cursor() -> void:
	if GameState.kbm_active:
		attack_direction = (mouse_pos - self.global_position).normalized()
	else:
		var right_joy_input = Input.get_vector("look_left", "look_right", "look_up", "look_down").normalized()
		if not right_joy_input.is_zero_approx():
			attack_direction = right_joy_input 
	
	cursor.global_position = self.global_position + (attack_direction*35)


# shotgun function
func shoot_shotgun():
	is_shooting = true
	shotgun_sound.play()
	
	shotgun_hitbox.enable()
	shotgun_hitbox.set_direction(attack_direction)
	
	%ShotgunCooldownTimer.start()
	level_state.hud.set_shotgun_on_cooldown()
	
	# direction is set when on frame 2 of animation
	shotgun_recoil_direction = Vector2.ZERO

func _on_shotgun_recoil_timer_timeout() -> void:
	is_shooting = false
	speed_multiplier = 1.0

func _on_shotgun_cooldown_timer_timeout() -> void:
	level_state.hud.set_shotgun_ready()


# slash functions
func slash(direction: Vector2):
	slash_hitbox.enable()
	slash_hitbox.set_direction(direction)

func _on_attack_animation_finished() -> void:
	if anim_sprite.animation == &"attack_shotgun":
		handle_animation()
	elif anim_sprite.animation.begins_with("attack"):
		slash_hitbox.disable()
		if anim_queue.is_empty():
			speed_multiplier = 1.0
			handle_animation()
		else:
			anim_sprite.play_attack_animation(attack_direction, anim_queue.pop_front())
			slash(attack_direction)


# damage to player functions
func hit(direction: Vector2) -> void:
	if not is_knocked:
		health_bar.hit()
		hit_invincibility.start()
		
		# Visual Hit Flash (Orange/Red)
		burn_timer.start()
		anim_sprite.modulate = Color(3, 1, 0.5) 
		var tween = get_tree().create_tween()
		tween.tween_property(anim_sprite, "modulate", Color(1.5, 0.8, 0.5), 0.3)
		
		is_knocked = true
		knockback_direction = direction.normalized()
		
		speed_multiplier = 3.0

func _on_hit_invincibility_timeout() -> void:
	is_knocked = false
	knockback_direction = Vector2(0, 0)
	speed_multiplier = 1.0

func _on_burn_timeout():
	anim_sprite.modulate = Color.WHITE 


# dash functions
func dash():
	is_dashing = true
	dash_sound.play()
	
	ghost_timer.start()
	dash_timer.start()
	
	dash_hitbox.monitoring = true
	set_collision_layer_value(2, false)
	set_collision_layer_value(6, true)
	set_collision_mask_value(3, false)
	
	%DashCooldownTimer.start()
	level_state.hud.set_dash_on_cooldown()
	
	speed_multiplier = 6.0
	dash_direction = move_direction

func _on_dash_timer_timeout() -> void:
	is_dashing = false
	dash_direction = Vector2(0, 0)
	
	ghost_timer.stop()
	dash_timer.stop()
	
	dash_hitbox.monitoring = false
	set_collision_layer_value(2, true)
	set_collision_layer_value(6, false)
	set_collision_mask_value(3, true)
	
	speed_multiplier = 1.0

func _on_dash_cooldown_timer_timeout() -> void:
	level_state.hud.set_dash_ready()

func add_dash_ghosting():
	var ghost = dash_ghost_effect.instantiate()
	ghost.set_position_and_scale(position, scale)
	ghost.flip(attack_direction.x < 0)
	get_parent().add_child(ghost)

func _on_ghost_effect_timer_timeout() -> void:
	add_dash_ghosting()

func _on_dash_hitbox_body_entered(body: Node2D) -> void:
	if body is Slime:
		body.hit()
	if body is FireGoblin:
		body.hit()


func _on_health_changed(value: float) -> void:
	if value <= 0:
		level_state.register_player_death()
