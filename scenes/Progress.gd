extends CanvasLayer

@export var player: Node2D
@export var level_start_x = 0.0
@export var level_end_x = 0.0

@onready var progress_bar = $TextureProgressBar
@onready var percent_label = $PercentLabel
@onready var best_label = $BestLabel

var percent = 0.0
var best_percent = 0.0
var level_finished = false

func _ready() -> void:
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.step = 0.01
	progress_bar.value = 0
	percent_label.text = "0%"
	best_label.text = "Best: " + str(int(GameManager.best_percent)) + "%"
	
func _process(delta: float) -> void:
	if level_finished == true:
		return
	
	var player_x = player.global_position.x
	var distance_traveled = player_x - level_start_x
	var total_distance = level_end_x - level_start_x
	
	percent = (distance_traveled / total_distance) * 100
	
	if percent < 0:
		percent = 0
	if percent > GameManager.best_percent:
		GameManager.best_percent = percent
		best_label.text = "Best: " + str(int(GameManager.best_percent)) + "%"
	
	progress_bar.value = percent
	
	percent_label.text = str(int(percent)) + "%"
	
	if percent >= 100:
		level_finished = true
		$CompleteScreen.show_complete(GameManager.attempts)
		print("verity co,mpleyted the level")

func reset_progress():
	percent = 0
	progress_bar.value = 0
	percent_label.text = "0%"
	level_finished = false
