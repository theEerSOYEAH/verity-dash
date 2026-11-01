extends Node

const SAVE_PATH = "user://save.cfg"

var attempts = 1
var best_percents = {}
var current_level = "level_1"

func _ready() -> void:
	load_game()

func get_best():
	if current_level in best_percents:
		return best_percents[current_level]
	return 0.0

func set_best(value):
	var old = get_best()
	best_percents[current_level] = value
	
	if int(value) != int(old):
		save_game()

func save_game():
	var config = ConfigFile.new()
	for id in best_percents:
		config.set_value("best", id, best_percents[id])
	config.save(SAVE_PATH)

func load_game():
	var config = ConfigFile.new()
	var error = config.load(SAVE_PATH)
	
	if error != OK:
		return
	
	if config.has_section("best"):
		for id in config.get_section_keys("best"):
			best_percents[id] = config.get_value("best", id)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
