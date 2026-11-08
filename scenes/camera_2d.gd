extends Camera2D

@export var player_path : NodePath
@export var player_offset_x = -200.0
@export var chatch_up_speed = 8.0

@export var margin = 40
@export var air_speed = 8
@export var ground_speed = 5
@export var fly_speed = 10

@export var player_screen_y = 0.6
@export var margin_y = 120.0
@export var y_follow_speed = 12.0
@export var y_catch_up = 1500

@export var follow_speed = 6.0
@export var player_x_offset = 250

var player 
var target_y = 0.0
@export var y_locked = false
var following = false

func _ready() -> void:
	
	add_to_group("camera")
	process_callback = $".".CAMERA2D_PROCESS_PHYSICS
	process_physics_priority = 100
	player = get_node(player_path)
	global_position.y = player.global_position.y  - y_offset()
	target_y = global_position.y


func snap_to_player():
	if player == null:
		return
	var p = player.global_position
	global_position.x = p.x - player_offset_x
	global_position.y = p.y - y_offset()
	target_y = global_position.y


func y_offset():
	var half_y = get_viewport_rect().size.y / 2 / zoom.y
	return half_y * (2.0 * player_screen_y - 1.0)

func set_y_lock(value: bool):
	y_locked = value

func start_following():
	following = true
	get_tree().call_group("background", "start_following")

func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	var p = player.global_position
	var c = global_position
	var y_off = y_offset()
	
	if following:
		c.x = p.x - player_offset_x
	
	if y_locked:
		var want_y = p.y - y_off
		var spd = ground_speed
		if player.mode != 0:
			spd = fly_speed
		elif not player.is_on_floor():
			spd = air_speed
		c.y = lerp(c.y, want_y, 1.0 - exp(-spd * delta))
	
		var off = p.y - (c.y + y_off)
		if off > margin:
			c.y = p.y -  y_off - margin 
		elif off < -margin:
			c.y = p.y - y_off + margin
	
	
	global_position = c



func shake(strength, duration):
	var tween = create_tween()
	for i in 10:
		var shake_offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		tween.tween_property(self, "offset", shake_offset, duration / 10)
	tween.tween_property(self, "offset", Vector2.ZERO, 0.05)


func _on_y_zone_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
