extends Area2D


@export var dash_angle := -45.0  


@export var ring_radius := 40.0
@export var ring_thickness := 5.0
@export var ring_color := Color(0.3, 0.9, 1.0, 0.9)  
@export var spin_speed := 2.5            
@export var arc_length_deg := 90.0       
@export var ring_offset := Vector2.ZERO  

var player_inside = null
var spin := 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = body


func _on_body_exited(body: Node2D) -> void:
	if body == player_inside:
		player_inside = null


 
func _physics_process(_delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("click"):
		player_inside.start_dash(dash_angle)
		player_inside = null



func _process(delta: float) -> void:
	spin += spin_speed * delta
	queue_redraw()



func _draw() -> void:
	var arc = deg_to_rad(arc_length_deg)
	for i in 3:
		var start = spin + i * TAU / 3.0
		draw_arc(ring_offset, ring_radius, start, start + arc, 24, ring_color, ring_thickness, true)
