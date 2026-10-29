extends Area2D


@export var launc_force = -600

var player_inside : CharacterBody2D = null
var used = false




# Called when the node enters the scene tree for the first time.



func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_inside = body
		used = false



func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == player_inside:
		player_inside = null

func _process(delta: float) -> void:
	if player_inside == null or used:
		return

	if Input.is_action_just_pressed("ui_accept"):
		player_inside.velocity.y = launc_force
		used = true
