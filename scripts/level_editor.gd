extends Node2D

var cells = {}

@export var normal_textures: Texture2D
@export var hover_textures: Texture2D
@export var pressed_textures: Texture2D
@export var button_font: Font
@export var button_font_size = 20
@export var button_outline_size = 4

var selected_id = "block"
var rotation_deg = 0
var ghost = null

@onready var camera = $Camera2D
@onready var objects = $Obects
@onready var palette = $UI/Pallet
@onready var name_edit = $UI/TopBar/NameEdit
@onready var save_button = $UI/TopBar/SaveButton
@onready var load_button = $UI/TopBar/LoadButton
@onready var back_button = $UI/TopBar/BackButton
@onready var play_button = $UI/TopBar/PlayButton
@onready var status_label = $UI/StatusLabel

var button_tweens = {}

func _ready() -> void:
	save_button.pressed.connect(save_level)
	load_button.pressed.connect(load_level)
	back_button.pressed.connect(go_back)
	play_button.pressed.connect(play_level)
	
	build_palette()
	select_object(selected_id)
	say("Left click: place   Right click: delete   R: rotate   Arrows: move")
	
	LevelObjects.playtesting = false
	if LevelObjects.editor_level_name != "":
		name_edit.text = LevelObjects.editor_level_name
		load_level()
	
	for button in [save_button, load_button, play_button, back_button]:
		setup_button(button)
		
func build_palette():
	for i in LevelObjects.ids.size():
		var button = Button.new()
		button.text = LevelObjects.names[i]
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(select_object.bind(LevelObjects.ids[i]))
		palette.add_child(button)
		style_button(button)
		setup_button(button)
		

func _process(delta: float) -> void:
	if name_edit.has_focus() == false:
		var move = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var speed = 600.0
		if Input.is_key_pressed(KEY_SHIFT):
			speed = 1400.0
		camera.position += move * speed * delta
	
	if ghost != null:
		ghost.position = LevelObjects.place_position(selected_id, get_mouse_cell(), rotation_deg)

	queue_redraw()

func _draw() -> void:
	var g = LevelObjects.GRID
	var view = get_viewport_rect().size / camera.zoom
	var top_left = camera.get_screen_center_position() - view / 2
	
	var x = floor(top_left.x / g) * g
	while x <= top_left.x + view.x:
		draw_line(Vector2(x, top_left.y), Vector2(x, top_left.y + view.y), Color(1, 1, 1, 0.1))
		x += g
	
	var y = floor(top_left.y / g) * g
	while y <= top_left.y + view.y:
		draw_line(Vector2(top_left.x, y), Vector2(top_left.x + view.x, y), Color(1, 1, 1, 0.1))
		y += g
	
	draw_line(Vector2(0, top_left.y), Vector2(0, top_left.y + view.y), Color(0.3, 1, 0.3, .6), 3)
	draw_line(Vector2(top_left.x, 0), Vector2(top_left.x + view.x, 0), Color(0.3, 1, 0.3, 0.6), 3)
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		get_viewport().gui_release_focus()
		if event.button_index == MOUSE_BUTTON_LEFT:
			place_at_mouse()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			delete_at_mouse()
		
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			place_at_mouse()
		if event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
			delete_at_mouse()
		
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			rotation_deg = (rotation_deg + 90) % 360
			make_ghost()
			
func get_mouse_cell():
	var m = get_global_mouse_position()
	var g = LevelObjects.GRID
	return Vector2i(floori	(m.x / g), floori(m.y / g))
	
func select_object(id):
	selected_id = id
	make_ghost()
	say("Selected "+ id)

func make_ghost():
	if ghost != null:
		ghost.queue_free()
		ghost = null
	
	ghost = LevelObjects.make(selected_id)
	if ghost == null:
		say("The scene for "+ selected_id + " was not found, check the paths in the level_objects.gd")
		return
	
	ghost.process_mode = Node.PROCESS_MODE_DISABLED
	ghost.modulate.a = 0.5
	ghost.rotation_degrees = rotation_deg
	ghost.z_index = 10
	add_child(ghost)

func place_at_mouse():
	place_object(get_mouse_cell(), selected_id, rotation_deg)

func delete_at_mouse():
	remove_object(get_mouse_cell())

func place_object(cell, id, rot):
	if cell in cells:
		if cells[cell]["id"] == id and cells[cell]["rot"] == rot:
			return
		remove_object(cell)
	
	var node = LevelObjects.make(id)
	if node == null:
		return
	
	node.position = LevelObjects.place_position(id, cell, rot)
	node.rotation_degrees = rot
	objects.add_child(node)
	cells[cell] = {"id": id, "rot": rot, "node": node}
	
func remove_object(cell):
	if cell in cells:
		cells[cell]["node"].queue_free()
		cells.erase(cell)

func clear_all():
	for cell in cells:
		cells[cell]["node"].queue_free()
	cells.clear()

func get_level_name():
	var level_name = name_edit.text.strip_edges().validate_filename()
	if level_name == "":
		level_name = "my_level"
	return level_name

func save_level():
	var list = []
	for cell in cells:
		list.append({
			"id": cells[cell]["id"],
			"x": cell.x,
			"y": cell.y,
			"rot": cells[cell]["rot"]
		})
	
	var level_name = get_level_name()
	if LevelObjects.save_level(level_name, list):
		say("Saved " + level_name + " (" + str(list.size()) + " objects)")
	else:
		say("Could not save the level")

func load_level():
	var level_name = get_level_name()
	var list = LevelObjects.load_level(level_name)
	if list == null:
		say("No level called " + level_name)
		return
	
	clear_all()
	for item in list:
		place_object(Vector2i(int(item["x"]), int(item["y"])), item["id"], int(item["rot"]))
	say("Loaded " + level_name)

func play_level():
	var has_finish = false
	for cell in cells:
		if cells[cell]["id"] == "finish":
			has_finish = true
	if has_finish == false:
		say("Place a finish line first")
		return
	
	save_level()
	var level_name= get_level_name()
	LevelObjects.play_level_name= level_name
	LevelObjects.editor_level_name = level_name
	LevelObjects.playtesting = true
	SceneTransition.change_scene("res://scenes/custom_level.tscn")
	

func say(text):
	status_label.text = text
	
func go_back():
	SceneTransition.change_scene("res://scenes/level_select.tscn")

func setup_button(button):
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	button.z_index = 1
	button.mouse_entered.connect(button_hover.bind(button))
	button.mouse_exited.connect(button_unhover.bind(button))
	button.button_down.connect(button_press.bind(button))
	button.button_up.connect(button_release.bind(button))

func button_hover(button):
	button.pivot_offset = button.size / 2
	animate_button(button, Vector2(1.15, 1.15), Color(1.4, 1.4, 1.4), 0.18, Tween.TRANS_BACK)

func button_unhover(button):
	animate_button(button, Vector2(1, 1), Color(1, 1, 1), 0.2, Tween.TRANS_QUAD)

func button_press(button):
	animate_button(button, Vector2(0.93, 0.93), Color(1.6, 1.6, 1.6), 0.08, Tween.TRANS_QUAD)

func button_release(button):
	if button.is_hovered():
		animate_button(button, Vector2(1.15, 1.15), Color(1.4, 1.4, 1.4), 0.15, Tween.TRANS_BACK)

func animate_button(button, target_scale, target_color, time, trans):
	var old = button_tweens.get(button)
	if old != null and old.is_valid():
		old.kill()
	
	var tween = create_tween()
	button_tweens[button] = tween
	tween.set_parallel(true)
	tween.set_trans(trans)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, time)
	tween.tween_property(button, "modulate", target_color, time)

func style_button(button):
	button.add_theme_stylebox_override("normal", make_style(normal_textures))
	button.add_theme_stylebox_override("hover", make_style(hover_textures))
	button.add_theme_stylebox_override("pressed", make_style(pressed_textures))
	
	button.custom_minimum_size = Vector2(120, 40)
	
	if button_font != null:
		button.add_theme_font_override("font", button_font)
	button.add_theme_font_size_override("font_size", button_font_size)
	
	button.add_theme_constant_override("outline_size", button_outline_size)
	
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color(1.4, 1.4, 1.4))
	button.add_theme_color_override("font_pressed_color", Color(0.8, 0.8, 0.8))
	button.add_theme_color_override("font_hover_pressed_color", Color(0.8, 0.8, 0.8))
	button.add_theme_color_override("font_focus_color", Color.WHITE)
	
func  make_style(texture):
	var style = StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = 24
	style.texture_margin_right = 24
	style.texture_margin_right = 24
	style.texture_margin_bottom = 24
	style.texture_margin_top = 24
	style.content_margin_left = 12
	style.content_margin_right = 12
	return style
