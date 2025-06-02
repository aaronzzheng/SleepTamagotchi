extends MarginContainer

# Export screens
@export var in_game_button: VBoxContainer
@export var in_game_menu: MarginContainer

# Export main menu buttons
@export var in_game_button_open: Button

# Export settings UI
@export var close_setting_button: Button

# Declare button arrays
var main_buttons: Array
var setting_buttons: Array

# Function performed at beginning
func _ready():
	main_buttons = [in_game_button_open]
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
