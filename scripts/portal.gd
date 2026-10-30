extends Area2D

enum Target { ROLL, SHIP, WAVE }
@export var target_mode : Target = Target.SHIP

@onready var visual : CanvasItem  = $Sprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	match target_mode:
		Target.ROLL : visual.modulate = Color.ORANGE
		Target.SHIP : visual.modulate = Color.CYAN
		Target.WAVE : visual.modulate = Color.MAGENTA


func _on_body_entered(body: Node2D) -> void:
	print("detected")
	if body.has_method("set_mode"):
		body.set_mode(target_mode)
