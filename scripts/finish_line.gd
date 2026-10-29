extends Area2D

@onready var particles = $CPUParticles2D
@onready var sound = $AudioStreamPlayer2D
var triggered = false

func _ready() -> void:
	Engine.time_scale = 1.0

func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
	if body.name == "verity":
		triggered = true
		sound.play()
		particles.restart()
		body.finish_level()
		get_tree().get_first_node_in_group("camera").shake(15, 0.5)
		Engine.time_scale = 0.3
		await get_tree().create_timer(1.0, true, false, true).timeout
		Engine.time_scale = 1.0
