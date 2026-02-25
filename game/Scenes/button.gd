extends Node2D

const BEDROOM_SCENE_PATH := "res://Scenes/Bedroom.tscn"

func _on_button_pressed():
	get_tree().change_scene_to_file(BEDROOM_SCENE_PATH)
