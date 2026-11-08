extends Node

const GRID = 50
const LEVEL_FOLDER = "user://levels/"

var ids = ["block","spike", "jump_pad", "jump_orb", "portal_ship", "finish"]
var names = ["Block", "Spike", "Jump Pad", "Jump orb", "Ship Portal", "Finish"]
var paths = [
	"res://scenes/block.tscn",
	"res://scenes/spike.tscn",
	"res://scenes/jumppad.tscn",
	"res://scenes/jump_orb.tscn",
	"res://scenes/shipportal.tscn",
	"res://scenes/finish_line.tscn"
	
]

var offset_cache = {}

func get_offset(id):
	if id in offset_cache:
		return offset_cache[id]
	var result = calculate_offset(id)
	offset_cache[id] = result
	return result

func calculate_offset(id):
	var node = make(id)
	if node == null:
		return Vector2.ZERO
	
	node.position = Vector2.ZERO
	node.rotation = 0
	
	var shape = find_shape(node)
	var result = Vector2.ZERO
	
	if shape != null:
		var t = Transform2D.IDENTITY
		var n = shape
		while n != null:
			t = n.transform * t
			if n == node:
				break
			n = n.get_parent()
		result = t.origin
	
	node.free()
	return result


func find_shape(node):
	if node is CollisionShape2D:
		return node
	for child in node.get_children():
		var found = find_shape(child)
		if found != null:
			return found
	return null

func place_position(id, cell, rot_deg):
	var center = cell_to_position(cell)
	return center - get_offset(id).rotated(deg_to_rad(rot_deg))

func make(id):
	var i = ids.find(id)
	if i == -1:
		return null
	if not ResourceLoader.exists(paths[i]):
		return null
	var scene = load(paths[i])
	return scene.instantiate()

func cell_to_position(cell):
	return Vector2(cell.x * GRID + GRID / 2.0, cell.y * GRID + GRID / 2.0)

func save_level(level_name, list):
	DirAccess.make_dir_recursive_absolute(LEVEL_FOLDER)
	var file = FileAccess.open(LEVEL_FOLDER + level_name + ".json", FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"name": level_name, "objects": list}))
	file.close()
	return true

func load_level(level_name):
	var path = LEVEL_FOLDER + level_name + ".json"
	if not FileAccess.file_exists(path):
		return null
	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(data) != TYPE_DICTIONARY:
		return null
	if not data.has("objects"):
		return null
	return data["objects"]
	
