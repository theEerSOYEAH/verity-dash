extends CanvasLayer

@onready var fade_rect = $ColorRect

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func change_scene(path):
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 0.5)
	await tween.finished
	
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
	
	await get_tree().process_frame
	
	var tween2 = create_tween()
	tween2.tween_property(fade_rect, "color:a", 0.0, 0.5)
	await tween2.finished
	
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
