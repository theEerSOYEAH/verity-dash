extends Node

var attempts = 1
var best_percents = {}
var current_level = "level_1"

func get_best():
	return best_percents.get(current_level, 0.0)

func set_best(value):
	best_percents[current_level] = value
