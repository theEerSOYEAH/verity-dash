extends Area2D


@export var launc_force = -600

const BUFFER_TIME = 0.12
const COYOTE_TIME = 0.08

var player_inside : CharacterBody2D = null
var last_player : CharacterBody2D = null
var used = false
var press_timer = 0.0
var exit_timer = 0.0



# Called when the node enters the scene tree for the first time.



func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_inside = body
		used = false



func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == player_inside:
		last_player = player_inside
		player_inside = null
		exit_timer = COYOTE_TIME


func _physics_process(delta: float) -> void:
	press_timer = max(press_timer - delta, 0.0)
	exit_timer = max(exit_timer - delta, 0.0)
	
	if Input.is_action_just_pressed("ui_accept"):
		press_timer = BUFFER_TIME
		
	var target = player_inside
	if target == null and exit_timer > 0.0:
		return
	
	if target == null or used or press_timer <= 0.0:
		return 
	
	target.velocity.y = launc_force
	used = true
	press_timer = 0.0
	
	
	
