extends Node2D

var cells = {}

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
@onready var status_label = $UI/StatusLabel

func _ready() -> void:
	save_button.pressed.connect(save_level)
	load_button.pressed.connect(load_level)
	back_button.pressed.connect(go_back)
	
	build_palette()
	select_object(selected_id)
	say("Left click: place   Right click: delete   R: rotate   Arrows: move")

func build_palette():
	for i in LevelObjects.ids.size():
		var button = Button.new()
		button.text = LevelObjects.names[i]
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(select_object.bind(LevelObjects.ids[i]))
		palette.add_child(button)
		

func _process(delta: float) -> void:
	if name_edit.has_focus() == false:
		var move = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var speed = 600.0
		if Input.is_key_pressed(KEY_SHIFT):
			speed = 1400.0
		camera.position += move * speed * delta
	
	if ghost != null:
		ghost.position = LevelObjects.cell_to_position(get_mouse_cell())

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
	
	node.position = LevelObjects.cell_to_position(cell)
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

func say(text):
	status_label.text = text
	
func go_back():
	SceneTransition.change_scene("res://scenes/level_select.tscn")
