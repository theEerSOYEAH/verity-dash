extends Area2D


@export var new_color := Color(0.1, 0.7, 0.2)   # darker green
@export var fade_time := 1.5


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().call_group("background", "change_color", new_color, fade_time)
