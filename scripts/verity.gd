extends CharacterBody2D

@export var checkpointscene : PackedScene
@export var is_practice_mode = false

@export var wave_color := Color(0.2, 0.8, 1.0):
	set(value):
		wave_color = value
		apply_wave_style()

@export var wave_width := 3.0:
	set(value):
		wave_width = value
		apply_wave_style()

var checkpoints : Array[Dictionary] = []

var ship_particles : CPUParticles2D

var wave_lines : Array[Line2D] = []
var wave_corners : Array[Vector2] = []
var last_pressing = false
var last_on_surface = false
var surface_y = 0.0
const TRAIL_LENGTH = 500

var dashing = false
var ring_radius = 0.0
var dash_angle = 0.0

const T = 250

const MUSIC_FADE_TIME = 0.4
@onready var explosion: AnimatedSprite2D = $explosion

const WAVE_ANGLE_PRESSED = -30
const WAVE_ANGLE_RELEASED = 110

const JUMP_BUFFER_TIME = 0.12
var jump_buffer_timer = 0.0
const COYOTE_TIME = 0.12
var coyote_timer = 0.0

#ball mode
const SPEED = 275.0
const JUMP_VELOCITY = -600
const GRAVITY = 2000
const ROLL_SPEED = 8.0

#ship mode
const SHIP_THRUST = -1800
const SHIP_GRAVITY = 1400
const SHIP_MAX_RISE = -450
const SHIP_MAX_FALL = 450

const WAVE_Y_MULT = 1.25

enum Mode { ROLL, SHIP, WAVE }
var mode : Mode = Mode.ROLL


@onready var roll: AnimatedSprite2D = $roll
@onready var plane_1: AnimatedSprite2D = $plane1
@onready var plane_2: AnimatedSprite2D = $plane2
@onready var wave_1: AnimatedSprite2D = $wave1
@onready var wave_2: AnimatedSprite2D = $wave2


var dead := false
var finishe = false

func _ready() -> void:
	add_to_group("player")
	var index = GameManager.skin_ids.find(GameManager.selected_skin)
	if index != -1:
		var frames = load(GameManager.skin_paths[index])
		roll.sprite_frames = frames
		roll.play(frames.get_animation_names()[0])
	update_sprites()
	
	ship_particles = make_particles(Color(1, 0.6, 0.1), 20, 4.0)
	make_wave_trail()
	
	var practice_music = get_node_or_null("AudioStreamPlayer2D2")
	var normal_music = get_node_or_null("AudioStreamPlayer2D")
	if is_practice_mode:
		if practice_music:
			practice_music.play()
	else:
		if normal_music:
			normal_music.play()


func start_dash(angle_deg:float):
	if mode != Mode.ROLL or dead or finishe:
		return
	dashing = true
	dash_angle = angle_deg
	coyote_timer = 0.0
	jump_buffer_timer = 0.0


func make_particles(color: Color, amount: int, size: float) -> CPUParticles2D:
	var p = CPUParticles2D.new()
	p.local_coords = false
	p.emitting = false
	p.amount = amount
	p.lifetime = 0.7
	p.explosiveness = 0.0
	
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(4, 6)
	
	p.direction = Vector2(0, -1)
	p.spread = 180
	p.initial_velocity_min = 5
	p.initial_velocity_max = 30
	p.gravity = Vector2.ZERO
	p.damping_min = 10.0
	p.damping_max = 25.0
	
	p.scale_amount_min = size * 0.5
	p.scale_amount_max = size
	p.position = Vector2(-18, 0)
	p.z_index = -1
	
	var shrink = Curve.new()
	shrink.add_point(Vector2(0, 1))
	shrink.add_point(Vector2(1, 0))
	p.scale_amount_curve = shrink
	
	var fade = Gradient.new()
	fade.set_color(0, color)
	fade.set_color(1, Color(color, 0.0))
	p.color_ramp = fade
	
	add_child(p)
	return(p)

func make_line(width: float, color: Color) -> Line2D:
	var l = Line2D.new()
	l.top_level = true
	l.width = width
	l.default_color = color
	l.joint_mode = Line2D.LINE_JOINT_ROUND
	l.begin_cap_mode = Line2D.LINE_CAP_ROUND
	l.end_cap_mode = Line2D.LINE_CAP_ROUND
	l.z_index = -1
	var mat = CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	l.material = mat
	add_child(l)
	l.position = Vector2.ZERO
	return l

func make_wave_trail():
	for i in 3:
		wave_lines.append(make_line(1.0, Color.WHITE))
	apply_wave_style()

func apply_wave_style():
	if wave_lines.size() < 3:
		return
	wave_lines[0].width = wave_width * 5.6
	wave_lines[0].default_color = Color(wave_color, 0.12)
	wave_lines[1].width = wave_width * 2.6
	wave_lines[1].default_color = Color(wave_color, 0.30)
	wave_lines[2].width = wave_width
	wave_lines[2].default_color = wave_color.lerp(Color.WHITE, 0.8)

func update_wave_trail():
	if dead:
		return
	if mode != Mode.WAVE or finishe:
		clear_wave_trails()
		return
	
	var head = global_position
	var pressing = Input.is_action_pressed("click")
	var on_surface = is_on_floor() or is_on_ceiling()
	
	if wave_corners.is_empty():
		wave_corners.append(head)
	elif on_surface and not last_on_surface:
		wave_corners.append(head)
	elif pressing != last_pressing:
		var corner = head
		if last_on_surface:
			corner.y = surface_y
		wave_corners.append(corner)
		
	if on_surface:
		surface_y = head.y
	last_on_surface = on_surface
	last_pressing = pressing
	
	var cut_x = head.x - TRAIL_LENGTH
	while wave_corners.size() > 1 and wave_corners[1].x < cut_x:
		wave_corners.remove_at(0)
	
	var pts = PackedVector2Array(wave_corners)
	pts.append(head)
	
	if pts.size() > 1 and pts[0].x < cut_x and pts[1].x != pts[0].x:
		var t = (cut_x - pts[0].x) / (pts[1].x - pts[0].x)
		pts[0] = pts[0].lerp(pts[1], t)
	
	for i in wave_lines:
		i.points = pts
	
func clear_wave_trails():
	wave_corners.clear()
	last_on_surface = false
	for l in wave_lines:
		l.clear_points()


func _process(delta: float) -> void:
	var target = 30.0 if dashing else 0.0
	ring_radius = move_toward(ring_radius, target, 500.0 * delta)
	queue_redraw()
	
	update_wave_trail()
	
	ship_particles.emitting = mode == Mode.SHIP and not dead and not finishe
	

func _draw():
	if ring_radius > 0.5:
		draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 48, Color(1, 1, 1, 0.9), 4.0)

func _unhandled_input(event: InputEvent) -> void:
	if not is_practice_mode or dead or finishe:
		return
	
	if event.is_action_pressed("practice_place"):
		place_checkpoint()
	elif event.is_action_pressed("practice_remove"):
		remove_checkpoint()

func place_checkpoint():
	var cp_data = {
		"position": global_position,
		"velocity": velocity,
		"mode": mode,
		"roll_rotation": roll.rotation,
		"plane_rotations": [plane_1.rotation, plane_2.rotation],
		"wave_rotation": wave_1.rotation,
		"node": null
	}


	if checkpointscene:
		var cp_instance = checkpointscene.instantiate()
		cp_instance.global_position = global_position
		get_tree().current_scene.add_child(cp_instance)
		cp_data["node"] = cp_instance
	checkpoints.append(cp_data)

func remove_checkpoint():
	if checkpoints.is_empty():
		return
	var removed_cp = checkpoints.pop_back()
	if removed_cp["node"] and is_instance_valid(removed_cp["node"]):
		removed_cp["node"].queue_free()

func respawn_at_checkpoint():
	if checkpoints.is_empty():
		get_tree().reload_current_scene()
		return

	var cam = get_tree().get_first_node_in_group("camera")

	dead = false
	dashing = false
	explosion.visible = false

	var cp = checkpoints.back()
	global_position = cp["position"]
	velocity = cp["velocity"]
	mode = cp["mode"]
	roll.rotation = cp["roll_rotation"]
	plane_1.rotation = cp["plane_rotations"][0]
	plane_2.rotation = cp["plane_rotations"][1]
	wave_1.rotation = cp["wave_rotation"]

	
	clear_wave_trails()
	update_sprites()


	if cam:
		cam.snap_to_player()

	var music = get_tree().get_first_node_in_group("music")
	if music and music.playing:
		var tween = create_tween()
		tween.tween_property(music, "volume_db", 0.0, 0.2)


func update_sprites():
	roll.visible = mode == Mode.ROLL
	plane_1.visible = mode == Mode.SHIP
	plane_2.visible = mode == Mode.SHIP
	wave_1.visible = mode == Mode.WAVE
	#wave_2.visible = mode == Mode.WAVE


func activate_sprites():
	match mode:
		Mode.SHIP: return [plane_1, plane_2]
		Mode.WAVE: return [wave_1, wave_2]
	return[roll]




func _physics_process(delta: float) -> void:
	if dead or finishe:
		return

	match mode:
		Mode.ROLL:
			_roll_physics(delta)
		Mode.SHIP:
			_ship_physics(delta)
		Mode.WAVE:
			_wave_physics()

	velocity.x = SPEED
	var start_x := global_position.x
	move_and_slide()

	#hiddenblockfinder (uncomment to print every block you touch)
	#for i in get_slide_collision_count():
		#var hit = get_slide_collision(i)
		#var obj = hit.get_collider()
		#print("hit ", obj.name, " at ", hit.get_position())

	
	var moved_x = global_position.x - start_x
	if is_on_wall() and moved_x < SPEED * delta * 0.5:
		die()
		return

	#headbumpdeath (roll mode only)
	if mode == Mode.ROLL and is_on_ceiling():
		die()
		return

func _roll_physics(delta: float):
	if dashing:
		if Input.is_action_pressed("click"):
			velocity.y = tan(deg_to_rad(dash_angle)) * SPEED
			roll.rotation += ROLL_SPEED * delta
			return
		dashing = false
		velocity.y = 0.0

	if not is_on_floor():
		velocity.y += GRAVITY * delta
		coyote_timer -= delta
	else:
		coyote_timer = COYOTE_TIME

	roll.rotation += ROLL_SPEED * delta

	if Input.is_action_just_pressed("click"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta

	var wants_jump = jump_buffer_timer > 0.0 or Input.is_action_pressed("click")
	if coyote_timer > 0.0 and wants_jump:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0
		jump_buffer_timer = 0.0

	
	
	

func _ship_physics(delta : float):
	if Input.is_action_pressed("click"):
		velocity.y += SHIP_THRUST * delta
	else:
		velocity.y += SHIP_GRAVITY * delta
		
	velocity.y = clamp(velocity.y, SHIP_MAX_RISE, SHIP_MAX_FALL)
	
	var target_angle = atan2(velocity.y, SPEED)
	plane_1.rotation = lerp_angle(plane_1.rotation, target_angle, 10.0 * delta)
	plane_2.rotation = lerp_angle(plane_2.rotation, target_angle, 10.0 * delta)
	

func _wave_physics():
	var pressing = Input.is_action_pressed("click")
	var dir = -1.0 if pressing else 1.0
	velocity.y = dir * SPEED * WAVE_Y_MULT

	
	wave_1.rotation = WAVE_ANGLE_PRESSED if pressing else WAVE_ANGLE_RELEASED
	#wave_2.rotation = atan2(velocity.y, SPEED)


func set_mode(new_mode :int):
	mode = new_mode as Mode
	velocity.y = 0.0
	roll.rotation = 0.0
	update_sprites()

func die():
	if dead or finishe:
		return
	dead = true
	dashing = false
	GameManager.attempts += 1
	velocity = Vector2.ZERO

	
	var will_respawn = is_practice_mode and not checkpoints.is_empty()
	if not will_respawn:
		fade_out_music()

	$explosionsound.play()
	roll.visible = false
	plane_1.visible = false
	plane_2.visible = false
	wave_1.visible = false
	explosion.visible = true
	explosion.play("default")
	await explosion.animation_finished

	if will_respawn:
		respawn_at_checkpoint()
	else:
		get_tree().reload_current_scene()


func fade_out_music():
	var music = get_tree().get_first_node_in_group("music")
	if music == null:
		return
	var tween = create_tween()
	tween.tween_property(music, "volume_db", -40.0, MUSIC_FADE_TIME)
	tween.tween_callback(music.stop)


func finish_level():
	finishe = true
	velocity = Vector2.ZERO

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 300, 1.0) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 1.0)
	tween.tween_property(roll, "rotation", roll.rotation + 12.0, 1.0)
	tween.tween_property(roll, "modulate:a", 0.0, 1.0)
