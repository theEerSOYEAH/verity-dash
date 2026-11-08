extends CanvasLayer

const HOVER_SCALE = Vector2(1.15, 1.15)
const PRESS_SCALE = Vector2(0.92, 0.92)
const HOVER_COLOR = Color(1.35, 1.35, 1.35)

@onready var place_button = $Buttons/PlaceButton
@onready var remove_button = $Buttons/RemoveButton

@onready var player = get_parent()

var tweens = {}

func _ready() -> void:
	place_button.pressed.connect(on_place_pressed)
	remove_button.pressed.connect(on_remove_pressed)
	
	for button in [place_button, remove_button]:
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.mouse_entered.connect(set_over_ui.bind(true))
		button.mouse_exited.connect(set_over_ui.bind(false))
		button.z_index = 1
		button.mouse_entered.connect(hover_button.bind(button))
		button.mouse_exited.connect(unhover_button.bind(button))
		button.button_down.connect(press_button.bind(button))
		button.button_up.connect(release_button.bind(button))

func on_place_pressed() -> void:
	if player.dead or player.finishe:
		return
	player.place_checkpoint()

func on_remove_pressed() -> void:
	if player.dead or player.finishe:
		return
	player.remove_checkpoint()

func set_over_ui(value) -> void:
	player.over_ui = value

func hover_button(button) -> void:
	SoundManager.play(SoundManager.hover_sound, 12)
	button.pivot_offset = button.size / 2
	animate_button(button, HOVER_SCALE, HOVER_COLOR, 0.2, Tween.TRANS_BACK)

func unhover_button(button) -> void:
	animate_button(button, Vector2.ONE, Color.WHITE, 0.25, Tween.TRANS_QUART)

func press_button(button) -> void:
	SoundManager.play(SoundManager.click_sound)
	animate_button(button, PRESS_SCALE, Color(1.6, 1.6, 1.6), 0.08, Tween.TRANS_QUAD)

func release_button(button) -> void:
	if button.is_hovered():
		animate_button(button, HOVER_SCALE, HOVER_COLOR, 0.2, Tween.TRANS_BACK)

func animate_button(button, target_scale, target_color, time, trans) -> void:
	var old = tweens.get(button)
	if old != null and old.is_valid():
		old.kill() 
	
	var tween = create_tween()
	tweens[button] = tween
	tween.set_parallel(true)
	tween.set_trans(trans)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, time)
	tween.tween_property(button, "modulate", target_color, time)

func _exit_tree() -> void:
	if player != null:
		player.over_ui = false
	
