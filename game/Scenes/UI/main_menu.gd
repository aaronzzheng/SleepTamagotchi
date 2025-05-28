extends MarginContainer

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

# Function performed per frame
func _process(_delta):
	update_button_scale()

# Animating buttons
func update_button_scale():
	for button in main_buttons:
		button_hov(button, 1.25, 0.2)
	for button in setting_buttons:
		button_hov(button, 1.25, 0.2)

func button_hov(button: Button, tweenSize, time):
	button.pivot_offset = button.size / 2
	if button.is_hovered():
		tween(button, "scale", Vector2.ONE * tweenSize, time)
	else:
		tween(button, "scale", Vector2.ONE, time)

func tween(button, property, amount, time):
	var tweenSize = create_tween()
	tweenSize.tween_property(button, property, amount, time)

# Toggle visability of menu
func toggle_visibility(object):
	object.visible = !object.visible

# Click control
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Bedroom.tscn")

func _on_setting_button_pressed() -> void:
	toggle_visibility(setting_menu_screen)
	toggle_visibility(main_menu_screen)

func _on_setting_close_button_pressed() -> void:
	toggle_visibility(setting_menu_screen)
	toggle_visibility(main_menu_screen)
