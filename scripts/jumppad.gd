extends Area2D


@export var jump_force = -800



func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.velocity.y = jump_force
		$Burst.restart()

func squash():
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "scale", Vector2(1.2, 0.7), 0.05)
	tween.tween_property($AnimatedSprite2D, "scale", Vector2(1, 1), 0.15)
