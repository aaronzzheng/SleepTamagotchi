extends Node2D


#func _on_left_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://Scenes/Bathroom.tscn")


#func _on_right_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://Scenes/Studyroom.tscn")

# Define the ordered scene list
var scenes = [
	"res://Scenes/Bedroom.tscn",
	"res://Scenes/Studyroom.tscn",
	"res://Scenes/Bathroom.tscn"
]

func _on_right_button_pressed() -> void:
	var current_scene_path = get_tree().current_scene.scene_file_path
	var current_index = scenes.find(current_scene_path)
	var next_index = (current_index + 1) % scenes.size()
	get_tree().change_scene_to_file(scenes[next_index])

func _on_left_button_pressed() -> void:
	var current_scene_path = get_tree().current_scene.scene_file_path
	var current_index = scenes.find(current_scene_path)
	var previous_index = (current_index - 1 + scenes.size()) % scenes.size()
	get_tree().change_scene_to_file(scenes[previous_index])
