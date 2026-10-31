extends CharacterBody2D

const T = 250

const MUSIC_FADE_TIME = 0.4
@onready var explosion: AnimatedSprite2D = $explosion


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


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var dead := false
var finishe = false


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
	
	sprite.rotation += ROLL_SPEED * delta
	
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
		sprite.rotation = lerp_angle(sprite.rotation, target_angle, 10.0 * delta)
		

func _wave_physics():
	var dir = -1.0 if Input.is_action_pressed("ui_accept") else 1.0
	velocity.y = dir * SPEED * WAVE_Y_MULT
	
	sprite.rotation = atan2(velocity.y, SPEED)



func set_mode(new_mode :int):
	mode = new_mode as Mode
	velocity.y = 0.0
	if mode == Mode.ROLL:
		sprite.rotation = 0.0

func die():
	if dead or finishe:
		return
	dead = true
	GameManager.attempts += 1
	velocity = Vector2.ZERO
	
	fade_out_music()
	
	$explosionsound.play()
	sprite.visible = false
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
	tween.tween_property(sprite, "rotation", sprite.rotation + 12.0, 1.0)
	tween.tween_property(sprite, "modulate:a", 0.0, 1.0)
	
