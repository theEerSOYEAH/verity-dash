extends Area2D


@export var camera_path : NodePath



func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("folowing")
		get_node(camera_path).start_following()
