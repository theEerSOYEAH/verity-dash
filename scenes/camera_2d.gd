extends Camera2D

@export var player_path : NodePath
@export var player_offset_x = -200.0
@export var chatch_up_speed = 8.0


@export var player_screen_y = 0.6
@export var margin_y = 120.0

@export var follow_speed = 6.0
@export var player_x_offset = 250

var player : Node2D
var target_y = 0.0
var following = false

func _ready() -> void:
	player = get_node(player_path)
	global_position.y = player.global_position.y  - y_offset()

func start_following():
	following = true

func y_offset():
	var half_y = get_viewport_rect().size.y / 2 / zoom.y
	return half_y * (2.0 * player_screen_y - 1.0)



func _process(delta: float) -> void:
	if player == null:
		return
	
	var half = get_viewport_rect().size / 2.0 / zoom
	var p = player.global_position
	var c = global_position
	
	if following:
		c.x = lerp(c.x, p.x - player_offset_x, chatch_up_speed * delta)
	
	var focus = c.y + y_offset()
	var top =  c.y - half.y + margin_y
	var bottom = c.y + half.y - margin_y
	

	if p.y < top:
		c.y -= top - p.y
	elif p.y > bottom:
		c.y += p.y - bottom
	
	global_position = c
	
