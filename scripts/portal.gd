extends Area2D

enum Target { ROLL, SHIP, WAVE }
@export var target_mode : Target = Target.SHIP

@onready var visual2: AnimatedSprite2D = $AnimatedSprite2D
@onready var visual: AnimatedSprite2D = $Sprite2D



func _ready() -> void:
	body_entered.connect(_on_body_entered)
	match target_mode:
		Target.ROLL : visual.modulate = Color.ORANGE
		Target.ROLL : visual2.modulate = Color.ORANGE
		Target.SHIP : visual.modulate = Color.CYAN
		Target.SHIP : visual2.modulate = Color.CYAN
		Target.WAVE : visual.modulate = Color.MAGENTA
		Target.WAVE : visual2.modulate = Color.MAGENTA


func _on_body_entered(body: Node2D) -> void:
	print("detected")
	if body.has_method("set_mode"):
		body.set_mode(target_mode)
