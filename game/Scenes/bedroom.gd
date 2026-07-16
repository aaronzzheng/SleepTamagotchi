extends "res://Scenes/interaction_room.gd"

func _ready() -> void:
	action_cooldown_seconds = 0.8
	super._ready()

func _handle_tap(pos: Vector2) -> String:
	if pos.y >= 300.0:
		return Stats.perform_rest()
	elif pos.x <= 150.0 and pos.y < 300.0:
		return Stats.perform_study()
	elif pos.x >= 300.0 and pos.y < 300.0:
		return Stats.perform_bathroom()
	return ""
