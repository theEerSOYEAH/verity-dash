extends Area2D


@export var jump_force = -800



func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.velocity.y = jump_force
