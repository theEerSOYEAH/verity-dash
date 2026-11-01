extends CanvasLayer

@onready var play_button = $PlayButton
@onready var quit_button = $QuitButton



func _on_play_button_pressed() -> void:
	SceneTransition.change_scene("res://scenes/main.tscn")


func _on_quit_button_pressed() -> void:
	pass
