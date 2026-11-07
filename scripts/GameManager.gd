extends Node

const SAVE_PATH = "user://save.cfg"

var attempts = 1
var best_percents = {}
var current_level = "level_1"
var points = 0
var run_points = 0
var owned_skins = ["verity"]
var selected_skin = "verity"

var skin_ids = ["verity", "falsity", "cruelty"]
var skin_names = ["Verity", "Falsity", "Cruelty"]
var skin_prices = [0, 150, 300]
var skin_paths = ["res://skins/verity.tres", "res://skins/falsity.tres", "res://skins/cruelty.tres"]

func _ready() -> void:
	load_game()

func get_best():
	if current_level in best_percents:
		return best_percents[current_level]
	return 0.0

func set_best(value):
	var old = get_best()
	best_percents[current_level] = value
	
	var new_percents = int(value) - int(old)
	if new_percents > 0:
		points += new_percents
		run_points += new_percents
		save_game()

func save_game():
	var config = ConfigFile.new()
	for id in best_percents:
		config.set_value("best", id, best_percents[id])
	
	config.set_value("shop", "points", points)
	config.set_value("shop", "owned", owned_skins)
	config.set_value("shop", "selected", selected_skin)
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
