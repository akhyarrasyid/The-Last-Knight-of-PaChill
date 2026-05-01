extends AnimatedSprite2D

var hit_sound: AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	
	hit_sound = AudioStreamPlayer2D.new()
	hit_sound.stream = load("res://assets/audio/fire saat hit badan player.wav")
	hit_sound.bus = "Master"
	add_child(hit_sound)
	
func play_explode_animation():
	self.show()
	hit_sound.play()
	play('default')
	

func _on_explosion_animation_finished() -> void:
	self.hide()
	if hit_sound.playing:
		await hit_sound.finished
	queue_free()
