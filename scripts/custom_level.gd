extends Node2D

@onready var objects = $Objects
@onready var back_button = $EditorUI/BackButton

func _ready() -> void:
	back_button.pressed.connect(back_to_editor)
	build_level()

func build_level():
	var list = LevelObjects.load_level(LevelObjects.play_level_name)
	if list == null:
		print("couldnt load level", LevelObjects.play_level_name)
		return
	
	for item in list:
		var id = item["id"]
		var rot = int(item["rot"])
		var cell = Vector2i(int(item["x"]), int(item["y"]))
		
		var node = LevelObjects.make(id)
		if node == null:
			continue
		
		node.position = LevelObjects.place_position(id, cell, rot)
		node.rotation_degrees = rot
		objects.add_child(node)

func back_to_editor():
	SceneTransition.change_scene("res://scenes/level_editor.tscn")
