extends AnimatedSprite2D


@export var follow_factor := 0.95   # higher = slower on screen, 1.0 = glued to the player


@export var start_color := Color(0.2, 0.5, 1.0)   # starting blue

var player
var following := false
var last_player_x := 0.0
var color_tween: Tween


func _ready() -> void:
	add_to_group("background")
	z_index = -100
	modulate = start_color

	
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if player:
		last_player_x = player.global_position.x



func start_following() -> void:
	following = true
	if player:
		last_player_x = player.global_position.x


func _physics_process(_delta: float) -> void:
	if player == null:
		return
	var px = player.global_position.x
	if following:
		global_position.x += (px - last_player_x) * follow_factor
	last_player_x = px



func change_color(new_color: Color, duration: float = 1.0) -> void:
	if color_tween:
		color_tween.kill()
	color_tween = create_tween()
	color_tween.tween_property(self, "modulate", new_color, duration)
