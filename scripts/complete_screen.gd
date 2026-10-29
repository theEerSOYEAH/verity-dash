extends CanvasLayer

@onready var dim = $Dim
@onready var flash = $Flash
@onready var title = $Title
@onready var ribbon = $Ribbon
@onready var stats_label = $StatsLabel
@onready var stats_rect = $StatsRect
@onready var buttons = $Buttons
@onready var retry_button = $Buttons/RetryButton
@onready var menu_button = $Buttons/MenuButton
@onready var confetti = $Confetti

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	
func show_complete(attempts):
	visible = true
	get_tree().paused = true
	stats_label.text = "Attempts: " + str(attempts)
	
	dim.modulate.a = 0
	flash.modulate.a = 0
	title.modulate.a = 0
	ribbon.modulate.a = 0
	stats_label.modulate.a = 0
	stats_rect.modulate.a = 0
	title.modulate.a = 0
	buttons.modulate.a = 0
	title.pivot_offset = title.size / 2
	title.scale = Vector2(0.2, 0.2)
	ribbon.pivot_offset = ribbon.size / 2
	ribbon.scale = Vector2(0.2, 0.2)
	
	var screen_size = get_viewport().get_visible_rect().size
	confetti.position = Vector2(screen_size.x / 2, screen_size.y)
	
	play_animation()

func play_animation():
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	tween.tween_property(flash, "modulate:a", 1.0, 0.05)
	tween.tween_property(flash, "modulate:a", 0.0, 0.4)
	
	tween.tween_property(dim, "modulate:a", 1.0, 0.3)
	
	tween.tween_callback(confetti.restart)
	
	tween.tween_property(title, "modulate:a", 1.0, 0.4)
	tween.parallel().tween_property(title, "scale", Vector2(1, 1), 0.7) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(ribbon, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(ribbon, "scale", Vector2(1, 1), 0.5) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(stats_label, "modulate:a", 1.0, 0.3)
	tween.tween_property(stats_rect, "modulate:a", 1.0, 0.3)
	tween.tween_property(buttons, "modulate:a", 1.0, 0.3)

func _on_retry_pressed():
	Engine.time_scale = 1.0
	GameManager.attempts += 1
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed():
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
	
