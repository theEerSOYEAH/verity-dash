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
	
