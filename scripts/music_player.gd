extends Node

@onready var lobby_music = AudioStreamPlayer.new()
@onready var main_music = AudioStreamPlayer.new()
@onready var transition_music = AudioStreamPlayer.new()
@onready var win_music = AudioStreamPlayer.new()
@onready var died_music = AudioStreamPlayer.new()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Keep playing even when paused
	
	lobby_music.stream = load("res://assets/audio/lobby game paling luar.mp3")
	lobby_music.bus = "Music"
	add_child(lobby_music)
	
	main_music.stream = load("res://assets/audio/bgm_main.wav")
	main_music.bus = "Music"
	add_child(main_music)
	
	transition_music.stream = load("res://assets/audio/selesai level 1 dan 2 untuk transisi.wav")
	transition_music.bus = "Music"
	add_child(transition_music)
	
	win_music.stream = load("res://assets/audio/win alias selesai level 3.wav")
	win_music.bus = "Music"
	add_child(win_music)
	
	died_music.stream = load("res://assets/audio/game over.wav")
	died_music.bus = "Music"
	add_child(died_music)

func play_lobby():
	if !lobby_music.playing:
		main_music.stop()
		lobby_music.play()

func play_main():
	if !main_music.playing:
		stop_all()
		main_music.play()

func play_transition():
	stop_all()
	transition_music.play()

func play_win():
	stop_all()
	win_music.play()

func play_died():
	stop_all()
	died_music.play()

func stop_all():
	lobby_music.stop()
	main_music.stop()
	transition_music.stop()
	win_music.stop()
	died_music.stop()
