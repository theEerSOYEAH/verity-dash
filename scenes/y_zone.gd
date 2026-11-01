extends Area2D





func _on_body_entered(body: Node2D) -> void:
	if body.name == "verity":
		print("22")
		$"../Camera2D".set_y_lock(true)
