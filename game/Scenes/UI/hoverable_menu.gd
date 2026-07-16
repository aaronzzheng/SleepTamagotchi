extends Control

func _wire_hover_animations(buttons: Array) -> void:
	for button in buttons:
		if button == null:
			continue
		button.pivot_offset = button.size / 2
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_button_mouse_exited.bind(button))

func _on_button_mouse_entered(button: Button) -> void:
	_animate_button_scale(button, 1.25, 0.2)

func _on_button_mouse_exited(button: Button) -> void:
	_animate_button_scale(button, 1.0, 0.2)

func _animate_button_scale(button: Button, target_scale: float, duration: float) -> void:
	var scale_tween = create_tween()
	scale_tween.tween_property(button, "scale", Vector2.ONE * target_scale, duration)
