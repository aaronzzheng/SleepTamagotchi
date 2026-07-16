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

var _chill_mode_toggle: CheckButton
var _settings_feedback_label: Label

# Function performed at beginning
func _ready():
	main_buttons = [start_button, setting_button, exit_button]
	setting_buttons = [close_setting_button]
	_wire_hover_animations(main_buttons)
	_wire_hover_animations(setting_buttons)
	_build_settings_content()
	_apply_day_night_ambiance()
	_show_welcome_message()

func _build_settings_content() -> void:
	var panel: Control = get_node("settingsContainer/VBoxContainer/NinePatchRect")

	_chill_mode_toggle = CheckButton.new()
	_chill_mode_toggle.text = "Chill Mode (pause decay)"
	_chill_mode_toggle.position = Vector2(10, 6)
	_chill_mode_toggle.size = Vector2(280, 28)
	_chill_mode_toggle.button_pressed = not Stats.decay_enabled
	_chill_mode_toggle.toggled.connect(_on_chill_mode_toggled)
	panel.add_child(_chill_mode_toggle)

	var theme_button := Button.new()
	theme_button.text = "Re-theme Pet (%d coins)" % Stats.THEME_CHANGE_COST
	theme_button.position = Vector2(10, 44)
	theme_button.size = Vector2(280, 28)
	theme_button.pressed.connect(_on_retheme_button_pressed)
	panel.add_child(theme_button)

	var reset_button := Button.new()
	reset_button.text = "Reset Pet"
	reset_button.position = Vector2(10, 80)
	reset_button.size = Vector2(280, 28)
	reset_button.pressed.connect(_on_reset_button_pressed)
	panel.add_child(reset_button)

	_settings_feedback_label = Label.new()
	_settings_feedback_label.position = Vector2(10, 114)
	_settings_feedback_label.size = Vector2(280, 60)
	_settings_feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_settings_feedback_label.add_theme_font_size_override("font_size", 12)
	panel.add_child(_settings_feedback_label)

func _on_chill_mode_toggled(pressed: bool) -> void:
	Stats.decay_enabled = not pressed

func _on_retheme_button_pressed() -> void:
	_settings_feedback_label.text = Stats.cycle_pet_theme()

func _on_reset_button_pressed() -> void:
	Stats.reset_game()
	_chill_mode_toggle.button_pressed = false
	_settings_feedback_label.text = "Pet reset!"

func _show_welcome_message() -> void:
	if not Stats.has_pending_welcome_message:
		return
	var banner := Label.new()
	banner.text = Stats.consume_welcome_message()
	banner.top_level = true
	banner.position = Vector2(20, 20)
	banner.size = Vector2(410, 90)
	banner.autowrap_mode = TextServer.AUTOWRAP_WORD
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.add_theme_font_size_override("font_size", 15)
	add_child(banner)
	var timer := get_tree().create_timer(6.0)
	timer.timeout.connect(func(): banner.queue_free())

func _apply_day_night_ambiance() -> void:
	var scene_root := get_parent()
	if scene_root == null:
		return
	var hour: int = Time.get_time_dict_from_system().get("hour", 12)
	var is_night := hour >= 21 or hour < 6
	var canvas_modulate := CanvasModulate.new()
	canvas_modulate.color = Color(0.55, 0.55, 0.78) if is_night else Color(1, 1, 1)
	scene_root.add_child.call_deferred(canvas_modulate)

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
