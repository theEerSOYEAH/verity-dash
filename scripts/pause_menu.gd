extends CanvasLayer

@export var player: Node2D
@export var blur_strength: = 2.5
@export var countdown_on_resume = true
@export var menu_scene_path = "res://scenes/main_menu.tscn"

var is_open = false
var busy = false
var buttons = []

@onready var blur = $Blur
@onready var dim = $Dim
@onready var window = $Window
@onready var resume_button = $Window/Buttons/ResumeButton
@onready var restart_button = $Window/Buttons/RestartButton
@onready var menu_button = $Window/Buttons/MenuButton
@onready var countdown_label = $CountdownLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	buttons = [resume_button, restart_button, menu_button]
	
	resume_button.pressed.connect(resume_game)
	restart_button.pressed.connect(restart_level)
	menu_button.pressed.connect(go_to_menu)
	
	for button in buttons:
		button.mouse_entered.connect(hover_button.bind(button))
		button.mouse_exited.connect(unhover_button.bind(button))
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_open:
			resume_game()
		else:
			opnem_menu()

func set_blur(amount):
	blur.material.set_shader_parameter("blur_amount", amount)

func opnem_menu():
	if is_open or busy:
		return
	if get_tree().paused:
		return
	if player != null:
		if player.finishe or player.dead:
			return
	
	is_open = true
	busy = true
	get_tree().paused = true
	
	dim.modulate.a = 0
	window.modulate.a = 0
	window.scale = Vector2(0.7, 0.7)
	for button in buttons:
		button.modulate.a = 0
		button.scale = Vector2(0.8, 0.8)
	set_blur(0.0)
	
	visible = true
	
	await get_tree().process_frame
	window.pivot_offset = window.size / 2
	for button in buttons:
		button.pivot_offset = button.size / 2
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	tween.tween_property(dim, "modulate:a", 1.0, 0.25)
	tween.tween_method(set_blur, 0.0, blur_strength, 0.25)
	tween.tween_property(window, "modulate:a", 1.0, 0.2)
	tween.tween_property(window, "scale", Vector2(1, 1), 0.35).set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)
	
	var delay = 0.15
	for button in buttons:
		tween.tween_property(button, "modulate:a", 1.0, 0.15).set_delay(delay)
		tween.tween_property(button, "scale", Vector2(1, 1), 0.25) \
			.set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		delay += 0.07
	
	await tween.finished
	busy = false

func resume_game():
	if busy or is_open == false:
		return
	busy = true
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	tween.tween_property(window, "modulate:a", 0.0, 0.15)
	tween.tween_property(window, "scale", Vector2(0.85, 0.85), 0.15)
	tween.tween_property(dim, "modulate:a", 0.0, 0.2)
	tween.tween_method(set_blur, blur_strength, 0.0, 0.2)
	await tween.finished
	
	if countdown_on_resume == true:
		await do_countdow()
	
	visible = false
	is_open = false
	busy = false
	get_tree().paused = false

func do_countdow():
	countdown_label.visible = true
	countdown_label.pivot_offset = countdown_label.size / 2
	
	for number in [3, 2, 1]:
		countdown_label.text = str(number)
		countdown_label.scale = Vector2(1.6, 1.6)
		countdown_label.modulate.a = 1.0
		
		var tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.set_parallel(true)
		tween.tween_property(countdown_label, "scale", Vector2(1, 1), 0.3) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(countdown_label, "modulate:a", 0.0, 0.25).set_delay(0.4)
		
		await get_tree().create_timer(0.8, true, false, true).timeout
	
	countdown_label.visible = false

func restart_level():
	if busy:
		return
	busy = true
	GameManager.attempts += 1
	SceneTransition.change_scene(get_tree().current_scene.scene_file_path)

func go_to_menu():
	if busy:
		return
	busy = true
	SceneTransition.change_scene(menu_scene_path)

func hover_button(button):
	if busy:
		return
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(button, "scale", Vector2(1.06, 1.06), 0.1)

func unhover_button(button):
	if busy:
		return
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(button, "scale", Vector2(1, 1), 0.1)
	
	
	
