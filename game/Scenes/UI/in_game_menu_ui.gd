extends Control

# Export screens
@export var in_game_button: MarginContainer
@export var in_game_menu: MarginContainer

# Export menu buttons
@export var open_button: Button
@export var close_button: Button
@export var setting_button: Button
@export var shop_button: Button
@export var stat_button: Button
@export var exit_button: Button

# Declare button arrays
var open_close_buttons: Array
var menu_buttons: Array

# Function performed at beginning
func _ready():
	open_close_buttons = [open_button, close_button]
	menu_buttons = [setting_button, shop_button, stat_button, exit_button]

# Function performed per frame
func _process(_delta):
	update_button_scale()

# Animating buttons
func update_button_scale():
	for button in open_close_buttons:
		button_hov(button, 1.25, 0.2)
	for button in menu_buttons:
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
func _on_open_button_pressed() -> void:
	toggle_visibility(in_game_button)
	toggle_visibility(in_game_menu)

func _on_close_button_pressed() -> void:
	toggle_visibility(in_game_button)
	toggle_visibility(in_game_menu)


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
