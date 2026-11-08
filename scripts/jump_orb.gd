extends Area2D

@export var launc_force = -600


@export var ring_radius = 40
@export var ring_thickness = 5
@export var ring_color := Color(1, 0.9, 0.2, 0.9)
@export var spin_speed := 2.5          # negative spins the other way
@export var arc_length_deg = 90        # 3 arcs of 90 leave 3 gaps of 30
@export var ring_offset := Vector2.ZERO  # moves the center of the circle (pixels)

const BUFFER_TIME = 0.12
const COYOTE_TIME = 0.08

var player_inside : CharacterBody2D = null
var last_player : CharacterBody2D = null
var used = false
var press_timer = 0.0
var exit_timer = 0.0
var spin = 0.0


func _ready() -> void:
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_shape_exited.is_connected(_on_body_shape_exited):
		body_shape_exited.connect(_on_body_shape_exited)


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



func _process(delta: float) -> void:
	spin += spin_speed * delta
	queue_redraw()


#
func _draw() -> void:
	var arc = deg_to_rad(arc_length_deg)
	for i in 3:
		var start = spin + i * TAU / 3.0
		draw_arc(ring_offset, ring_radius, start, start + arc, 24, ring_color, ring_thickness, true)
