extends CanvasLayer

@onready var play_button = $PlayButton
@onready var quit_button = $QuitButton


func _ready() -> void:
	play_button.mouse_entered.connect(hover_button.bind(play_button))
	play_button.mouse_exited.connect(unhover_button.bind(play_button))
	quit_button.mouse_entered.connect(hover_button.bind(quit_button))
	quit_button.mouse_exited.connect(unhover_button.bind(quit_button))
	play_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	quit_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	await get_tree().process_frame
	play_button.pivot_offset = play_button.size / 2
	quit_button.pivot_offset = quit_button.size / 2

func hover_button(button):
	SoundManager.play(SoundManager.hover_sound, -12)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(button, "modulate", Color(1.4, 1.4, 1.4), 0.1)
	
func unhover_button(button):
	SoundManager.play(SoundManager.hover_sound, -12)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1, 1), 0.1)
	tween.tween_property(button, "modulate", Color(1, 1, 1), 0.1)
	
func _on_play_button_pressed() -> void:
	SoundManager.play(SoundManager.click_sound)
	SceneTransition.change_scene("res://scenes/level_select.tscn")


func _on_quit_button_pressed() -> void:
	SoundManager.play(SoundManager.click_sound)
	GameManager.save_game()
	get_tree().quit()
