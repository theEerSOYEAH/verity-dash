extends CharacterBody2D

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
	update_sprites()


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
	move_and_slide()
	
	for i in get_slide_collision_count():
		var hit = get_slide_collision(i)
		var n = hit.get_normal()
		if abs(hit.get_normal().x) > 0.9:
			die()
			return
		if mode == Mode.ROLL and n.y > 0.9:
			die()
			return
	

func _roll_physics(delta: float):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		coyote_timer -= delta
	else:
		coyote_timer = COYOTE_TIME
	
	roll.rotation += ROLL_SPEED * delta
	
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta
	
	var wants_jump = jump_buffer_timer > 0.0 or Input.is_action_pressed("ui_accept")
	if coyote_timer > 0.0 and wants_jump:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0
		jump_buffer_timer = 0.0 
	
	
	

func _ship_physics(delta : float):
	if Input.is_action_pressed("ui_accept"):
		velocity.y += SHIP_THRUST * delta
	else:
		velocity.y += SHIP_GRAVITY * delta
		
	velocity.y = clamp(velocity.y, SHIP_MAX_RISE, SHIP_MAX_FALL)
	
	var target_angle = atan2(velocity.y, SPEED)
	plane_1.rotation = lerp_angle(plane_1.rotation, target_angle, 10.0 * delta)
	plane_2.rotation = lerp_angle(plane_2.rotation, target_angle, 10.0 * delta)
	

func _wave_physics():
	var pressing = Input.is_action_pressed("ui_accept")
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
	GameManager.attempts += 1
	velocity = Vector2.ZERO
	
	fade_out_music()
	
	$explosionsound.play()
	roll.visible = false
	plane_1.visible = false
	plane_2.visible = false
	wave_1.visible = false
	explosion.visible = true
	explosion.play("default")
	await explosion.animation_finished
	
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
	
