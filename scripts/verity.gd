extends CharacterBody2D

const COYOTE_TIME = 0.12
var coyote_timer = 0.0

#ball mode
const SPEED = 300.0
const JUMP_VELOCITY = -600
const GRAVITY = 2000
const ROLL_SPEED = 8.0

#ship mode
const SHIP_THRUST = -1800
const SHIP_GRAVITY = 1400
const SHIP_MAX_RISE = -450
const SHIP_MAX_FALL = 450
enum Mode { ROLL, SHIP}
var mode : Mode = Mode.ROLL


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var dead := false



func _physics_process(delta: float) -> void:
	if dead:
		return
	
	match mode:
		Mode.ROLL:
			_roll_physics(delta)
		Mode.SHIP:
			_ship_physics(delta)
	
	
	velocity.x = SPEED
	move_and_slide()

func _roll_physics(delta: float):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		coyote_timer -= delta
	else:
		coyote_timer = COYOTE_TIME
	
	sprite.rotation += ROLL_SPEED * delta
	
	if coyote_timer > 0.0 and Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0

func _ship_physics(delta : float):
	if Input.is_action_pressed("ui_accept"):
		velocity.y += SHIP_THRUST * delta
	else:
		velocity.y = clamp(velocity.y, SHIP_MAX_RISE, SHIP_MAX_FALL)
		
		velocity.y = clamp(velocity.y, SHIP_MAX_RISE, SHIP_MAX_FALL)
		
		var target_angle = atan2(velocity.y, SPEED)
		sprite.rotation = lerp_angle(sprite.rotation, target_angle, 10.0 * delta)
		

func set_mode(new_mode :int):
	mode = new_mode
	velocity.y = 0.0
	if mode == Mode.ROLL:
		sprite.rotation = 0.0




func die():
	GameManager.attempts += 1
	
	dead = true
	get_tree().reload_current_scene()
