extends Node

var click_sound = load("res://assets/Audio/click_001.ogg")
var hover_sound = load("res://assets/Audio/drop_003.ogg")
var back_sound = load("res://assets/Audio/switch_001.ogg")
var win_sound = load("res://assets/Audio/confirmation_001.ogg")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func play(sound, volume = 0.0):
	var player = AudioStreamPlayer.new()
	player.stream = sound
	player.volume_db = volume
	player.pitch_scale = randf_range(0.95, 1.05)
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
