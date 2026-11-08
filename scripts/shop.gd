extends Control

var current_index = 0

@onready var preview = $Card/Content/Preview
@onready var name_label = $NameLabel
@onready var price_label = $PriceLabel
@onready var left_button = $LeftButton
@onready var right_button = $RightButton
@onready var action_button = $ActionButton
@onready var points_label = $PointsLabel
@onready var page_label = $Card/Content/PageLabel
@onready var back_button = $BackButton
@onready var card = $Card
@onready var content = $Card/Content

var changing = false
var content_start_x = 0.0

func _ready() -> void:
		left_button.pressed.connect(go_left)
		right_button.pressed.connect(go_right)
		action_button.pressed.connect(on_action_pressed)
		back_button.pressed.connect(go_back)
		
		current_index = GameManager.skin_ids.find(GameManager.selected_skin)
		if current_index == -1:
			current_index = 0
		
		show_skin()
		
		for button in [left_button, right_button, action_button, back_button]:
			button.mouse_entered.connect(hover_button.bind(button))
			button.mouse_exited.connect(unhover_button.bind(button))
			button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		await get_tree().process_frame
		content_start_x = content.position.x
		for button in [left_button, right_button, action_button, back_button]:
			button.pivot_offset = button.size / 2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		go_left()
	if event.is_action_pressed("ui_right"):
		go_right()

func show_skin():
	var id = GameManager.skin_ids[current_index]
	var price = GameManager.skin_prices[current_index]
	
	var frames = load(GameManager.skin_paths[current_index])
	var anim = frames.get_animation_names()[0]
	preview.texture = frames.get_frame_texture(anim, 0)
	
	name_label.text = GameManager.skin_names[current_index]
	points_label.text = "Points: " + str(GameManager.points)
	page_label.text = str(current_index + 1) + " / " + str(GameManager.skin_ids.size())
	
	if id in GameManager.owned_skins:
		preview.modulate = Color(1, 1, 1)
	else:
		preview.modulate = Color(0.3, 0.3, 0.3)
	
	if id == GameManager.selected_skin:
		action_button.text = "EQUIPPED"
		action_button.disabled = true
		price_label.text = ""
	elif id in GameManager.owned_skins:
		action_button.text = "EQUIP"
		action_button.disabled = false
		price_label.text = "OWNED"
	else:
		action_button.text = "BUY"
		action_button.disabled = false
		price_label.text = str(price) + " pts"
		

func on_action_pressed():
	SoundManager.play(SoundManager.click_sound)
	if changing == true:
		return
	
	var id = GameManager.skin_ids[current_index]
	var price = GameManager.skin_prices[current_index]
	
	if id in GameManager.owned_skins:
		GameManager.selected_skin = id
		GameManager.save_game()
	else:
		if GameManager.points >= price:
			GameManager.points -= price
			GameManager.owned_skins.append(id)
			GameManager.selected_skin = id
			GameManager.save_game()
		else:
			not_enought_points()
			return
			
	show_skin()

func not_enought_points():
	var tween = create_tween()
	tween.tween_property(price_label, "modulate", Color(1, 0.3, 0.3), 0.1)
	tween.tween_property(price_label, "modulate", Color(1, 1, 1), 0.3)

func go_left():
	change_skin(-1)

func go_right():
	change_skin(1)

func change_skin(direction):
	if changing == true:
		return
	SoundManager.play(SoundManager.click_sound)
	changing = true
	
	var new_index = current_index + direction
	if new_index < 0:
		new_index = GameManager.skin_ids.size() - 1
	if new_index >= GameManager.skin_ids.size():
		new_index = 0
		
	var slide_distance = card.size.x
	
	var tween1 = create_tween()
	tween1.set_parallel(true)
	tween1.tween_property(content, "position:x", content_start_x - direction * slide_distance, 0.2)
	tween1.tween_property(content, "modulate:a", 0.0, 0.2 )
	await tween1.finished
	
	current_index = new_index
	show_skin()
	
	content.position.x = content_start_x + direction * slide_distance
	
	var tween2 = create_tween()
	tween2.set_parallel(true)
	tween2.tween_property(content, "position:x", content_start_x, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween2.tween_property(content, "modulate:a", 1.0, 0.3)
	await tween2.finished
	
	changing = false
	

func hover_button(button):
	SoundManager.play(SoundManager.hover_sound, -12)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "modulate", Color(1.3, 1.3, 1.3), 0.12)

func unhover_button(button):
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1, 1), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "modulate", Color(1, 1, 1), 0.12)



func go_back():
	SoundManager.play(SoundManager.back_sound)
	SceneTransition.change_scene("res://scenes/main_menu.tscn")
