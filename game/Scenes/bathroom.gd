extends "res://Scenes/interaction_room.gd"

func _get_intro_message() -> String:
	return "Tap anywhere for bathroom care"

func _handle_tap(_pos: Vector2) -> String:
	return Stats.perform_bathroom()
