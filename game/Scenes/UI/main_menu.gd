extends "res://Scenes/UI/hoverable_menu.gd"

const BEDROOM_SCENE_PATH := "res://Scenes/Bedroom.tscn"

# Export screens
@export var main_menu_screen: VBoxContainer
@export var setting_menu_screen: MarginContainer

# Export main menu buttons
@export var start_button: Button
@export var setting_button: Button
@export var exit_button: Button

# Export settings UI
@export var close_setting_button: Button

# Declare button arrays
var main_buttons: Array
var setting_buttons: Array

# Function performed at beginning
func _ready():
	main_buttons = [start_button, setting_button, exit_button]
	setting_buttons = [close_setting_button]
	_wire_hover_animations(main_buttons)
	_wire_hover_animations(setting_buttons)

# Toggle visability of menu
func toggle_visibility(object):
	object.visible = !object.visible

# Click control
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(BEDROOM_SCENE_PATH)

func _on_setting_button_pressed() -> void:
	toggle_visibility(setting_menu_screen)
	toggle_visibility(main_menu_screen)

func _on_setting_close_button_pressed() -> void:
	toggle_visibility(setting_menu_screen)
	toggle_visibility(main_menu_screen)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
