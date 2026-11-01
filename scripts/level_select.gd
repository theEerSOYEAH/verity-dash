extends Control

var level_ids = ["level_1", "level_2", "level_3"]
var level_names = ["Verity Rush", "Verity Madness", "Its Me!"]
var level_paths = ["res://scenes/main.tscn", "res://scenes/main.tscn", "res://scenes/main.tscn"]
var level_textures = [
	load("res://assets/basic black/button square hover.png"),
	load("res://assets/basic black/button square idle.png"),
	load("res://assets/basic black/button square clicked.png")
]

var current_index = 0
var changing = false
var card_start_x = 0.0

@onready var background = $Background
@onready var card = $Card
@onready var name_label = $Card/NameLabel
@onready var best_label = $Card/BestLabel
@onready var progress_bar = $Card/TextureProgressBar
@onready var page_label = $PageLabel
@onready var left_button = $Card/LeftButton
@onready var right_button = $Card/RightButton
@onready var ribbon = $Card/Ribbon
@onready var back_button = $BackButton


var ribbon_scale = Vector2(1, 1)
var name_scale = Vector2(1, 1)
var bar_scale = Vector2(5, 5)
var best_scale = Vector2(0.5, 0.5)

func _ready() -> void:
	left_button.pressed.connect(go_left)
	right_button.pressed.connect(go_right)
	ribbon.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	back_button.pressed.connect(go_back)
	
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	best_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	
	await get_tree().process_frame
	ribbon_scale = ribbon.scale
	name_scale = name_label.scale
	bar_scale = progress_bar.scale
	best_scale = best_label.scale
	card_start_x = card.position.x

	left_button.pivot_offset = left_button.size / 2
	right_button.pivot_offset = right_button.size / 2
	
	ribbon.pressed.connect(play_level)
	ribbon.mouse_entered.connect(ribbon_hover)
	ribbon.mouse_exited.connect(ribbon_unhover)
	
	show_level()
	background.texture = level_textures[current_index]
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		go_left()
	if event.is_action_pressed("ui_right"):
		go_right()
	if event.is_action_pressed("ui_accept"):
		play_level()

func show_level():
	var id = level_ids[current_index]
	
	var best = 0
	if id in GameManager.best_percents:
		best = GameManager.best_percents[id]
	
	name_label.text = level_names[current_index]
	best_label.text = "Best: " + str(int(best)) + "%"
	progress_bar.value = best
	page_label.text = str(current_index + 1) + " / " + str(level_names.size())

func go_left():
	change_level(-1)

func go_right():
	change_level(1)
	
func change_level(direction):
	if changing == true:
		return
	changing = true
	
	if direction == -1:
		pop_button(left_button)
	else:
		pop_button(right_button)
	
	var new_index = current_index + direction
	
	if new_index < 0:
		new_index = level_names.size() - 1
	if new_index >= level_names.size():
		new_index = 0
	
	var screen_width = get_viewport_rect().size.x
	
	var tween_1 = create_tween()
	tween_1.set_parallel(true)
	tween_1.tween_property(background, "modulate:a", 0.0, 0.2)
	tween_1.tween_property(card, "position:x", card_start_x - direction * screen_width, 0.2)
	await tween_1.finished
	
	current_index = new_index
	show_level()
	background.texture = level_textures[current_index]
	
	card.position.x = card_start_x + direction * screen_width
	
	var tween_2 = create_tween()
	tween_2.set_parallel(true)
	tween_2.tween_property(background, "modulate:a", 1.0, 0.3)
	tween_2.tween_property(card, "position:x", card_start_x, 0.3)
	await tween_2.finished
	
	changing = false

func pop_button(button):
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.3, 1.3), 0.08)
	tween.tween_property(button, "scale", Vector2(1, 1), 0.15)

func ribbon_hover():
	hover_ribbon()
	hover_name()
	hover_bar()
	hover_best()

func ribbon_unhover():
	unhover_ribbon()
	unhover_name()
	unhover_bar()
	unhover_best()

func hover_ribbon():
	ribbon.pivot_offset = ribbon.size / 2
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(ribbon, "modulate", Color(1.4, 1.4, 1.4), 0.1)
	tween.tween_property(ribbon, "scale", ribbon_scale * 1.05, 0.1)

func hover_name():
	name_label.pivot_offset = name_label.size / 2
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(name_label, "modulate", Color(1.4, 1.4, 1.4), 0.1)
	tween.tween_property(name_label, "scale", name_scale * 1.05, 0.1)

func hover_bar():
	progress_bar.pivot_offset = progress_bar.size / 2
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(progress_bar, "modulate", Color(1.4, 1.4, 1.4), 0.1)
	tween.tween_property(progress_bar, "scale", bar_scale * 1.05, 0.1)

func hover_best():
	best_label.pivot_offset = best_label.size / 2
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(best_label, "modulate", Color(1.4, 1.4, 1.4), 0.1)
	tween.tween_property(best_label, "scale", best_scale * 1.05, 0.1)


func unhover_ribbon():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(ribbon, "modulate", Color(1, 1, 1), 0.1)
	tween.tween_property(ribbon, "scale", ribbon_scale, 0.1)

func unhover_name():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(name_label, "modulate", Color(1, 1, 1), 0.1)
	tween.tween_property(name_label, "scale", name_scale, 0.1)

func unhover_bar():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(progress_bar, "modulate", Color(1, 1, 1), 0.1)
	tween.tween_property(progress_bar, "scale", bar_scale, 0.1)

func unhover_best():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(best_label, "modulate", Color(1, 1, 1), 0.1)
	tween.tween_property(best_label, "scale", best_scale, 0.1)


func play_level():
	if changing == true:
		return
	
	GameManager.current_level = level_ids[current_index]
	GameManager.attempts = 1
	SceneTransition.change_scene(level_paths[current_index])

func go_back():
	SceneTransition.change_scene("res://scenes/main_menu.tscn")
