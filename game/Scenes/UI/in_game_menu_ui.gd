extends Control

const MAIN_SCENE_PATH := "res://Scenes/Main.tscn"
const BEDROOM_SCENE_PATH := "res://Scenes/Bedroom.tscn"
const STUDYROOM_SCENE_PATH := "res://Scenes/Studyroom.tscn"
const BATHROOM_SCENE_PATH := "res://Scenes/Bathroom.tscn"
const SHOP_FOOD_COST := 5
const SHOP_FOOD_GAIN := 20.0

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

var open_close_buttons: Array
var menu_buttons: Array

var _status_label: Label
var _summary_panel: PanelContainer
var _summary_label: RichTextLabel

func _ready() -> void:
	open_close_buttons = [open_button, close_button]
	menu_buttons = [setting_button, shop_button, stat_button, exit_button]
	_wire_hover_animations(open_close_buttons)
	_wire_hover_animations(menu_buttons)
	_wire_button_actions()
	_build_status_hud()
	_build_summary_panel()
	_update_button_tooltips()
	_refresh_summary()

func _process(_delta: float) -> void:
	if _status_label != null:
		_status_label.text = "Mood: %s  |  Quest: %s" % [Stats.mood, Stats.get_active_quest_text()]
	if _summary_panel != null and _summary_panel.visible:
		_refresh_summary()

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

func _wire_button_actions() -> void:
	if setting_button != null and not setting_button.pressed.is_connected(_on_setting_button_pressed):
		setting_button.pressed.connect(_on_setting_button_pressed)
	if shop_button != null and not shop_button.pressed.is_connected(_on_shop_button_pressed):
		shop_button.pressed.connect(_on_shop_button_pressed)
	if stat_button != null and not stat_button.pressed.is_connected(_on_stat_button_pressed):
		stat_button.pressed.connect(_on_stat_button_pressed)

func _update_button_tooltips() -> void:
	if setting_button != null:
		setting_button.tooltip_text = "Move between Bedroom, Studyroom, and Bathroom"
	if shop_button != null:
		shop_button.tooltip_text = "Buy snack: -%d coins, +%d food" % [SHOP_FOOD_COST, int(SHOP_FOOD_GAIN)]
	if stat_button != null:
		stat_button.tooltip_text = "Show or hide session summary"

func _build_status_hud() -> void:
	_status_label = Label.new()
	_status_label.position = Vector2(8, 8)
	_status_label.size = Vector2(430, 24)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_status_label.add_theme_font_size_override("font_size", 13)
	_status_label.z_index = 20
	add_child(_status_label)

func _build_summary_panel() -> void:
	_summary_panel = PanelContainer.new()
	_summary_panel.visible = false
	_summary_panel.position = Vector2(30, 70)
	_summary_panel.size = Vector2(390, 260)
	_summary_panel.z_index = 30
	add_child(_summary_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	_summary_panel.add_child(margin)

	_summary_label = RichTextLabel.new()
	_summary_label.fit_content = true
	_summary_label.scroll_active = true
	_summary_label.bbcode_enabled = false
	margin.add_child(_summary_label)

func _refresh_summary() -> void:
	if _summary_label == null:
		return
	_summary_label.text = Stats.get_summary_text()

# Toggle visibility of menu
func toggle_visibility(object: CanvasItem) -> void:
	object.visible = !object.visible

func _on_open_button_pressed() -> void:
	toggle_visibility(in_game_button)
	toggle_visibility(in_game_menu)

func _on_close_button_pressed() -> void:
	toggle_visibility(in_game_button)
	toggle_visibility(in_game_menu)
	if _summary_panel != null:
		_summary_panel.visible = false

func _on_setting_button_pressed() -> void:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return
	var scene_name := current_scene.name.to_lower()

	if scene_name.find("bedroom") != -1:
		get_tree().change_scene_to_file(STUDYROOM_SCENE_PATH)
	elif scene_name.find("study") != -1:
		get_tree().change_scene_to_file(BATHROOM_SCENE_PATH)
	else:
		get_tree().change_scene_to_file(BEDROOM_SCENE_PATH)

func _on_shop_button_pressed() -> void:
	if Stats.spend_coins(SHOP_FOOD_COST):
		Stats.adjust_food(SHOP_FOOD_GAIN)
		shop_button.modulate = Color(0.85, 1.0, 0.85, 1)
	else:
		shop_button.modulate = Color(1.0, 0.8, 0.8, 1)

func _on_stat_button_pressed() -> void:
	if _summary_panel == null:
		return
	_summary_panel.visible = not _summary_panel.visible
	if _summary_panel.visible:
		_refresh_summary()

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)
