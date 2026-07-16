extends Node2D

const NOTIFICATION_BG := preload("res://Assets/UI/MainMenu/SettingsBG.png")
const NOTIFICATION_CLOSE := preload("res://Assets/UI/MainMenu/SettingsClose.png")

var action_cooldown_seconds := 0.6

var _cooldown := 0.0
var _message_timer := 0.0
var _message_label: Label
var _warning_label: Label

var _notification_panel: NinePatchRect
var _notification_label: Label
var _pending_notifications: Array[String] = []

func _ready() -> void:
	_message_label = Label.new()
	_message_label.position = Vector2(10, 420)
	_message_label.size = Vector2(430, 24)
	_message_label.add_theme_font_size_override("font_size", 14)
	add_child(_message_label)

	_warning_label = Label.new()
	_warning_label.position = Vector2(10, 396)
	_warning_label.size = Vector2(430, 20)
	_warning_label.add_theme_font_size_override("font_size", 13)
	_warning_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	_warning_label.visible = false
	add_child(_warning_label)

	_build_notification_popup()

	var intro := _get_intro_message()
	if intro != "":
		_show_message(intro)

func _build_notification_popup() -> void:
	_notification_panel = NinePatchRect.new()
	_notification_panel.texture = NOTIFICATION_BG
	_notification_panel.patch_margin_left = 10
	_notification_panel.patch_margin_top = 10
	_notification_panel.patch_margin_right = 10
	_notification_panel.patch_margin_bottom = 10
	_notification_panel.size = Vector2(360, 160)
	_notification_panel.position = Vector2(45, 145)
	_notification_panel.visible = false
	_notification_panel.z_index = 50
	add_child(_notification_panel)

	_notification_label = Label.new()
	_notification_label.position = Vector2(16, 16)
	_notification_label.size = Vector2(328, 100)
	_notification_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_notification_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_notification_label.add_theme_font_size_override("font_size", 16)
	_notification_panel.add_child(_notification_label)

	var close_button := TextureButton.new()
	close_button.texture_normal = NOTIFICATION_CLOSE
	close_button.position = Vector2(320, 4)
	close_button.size = Vector2(32, 32)
	close_button.pressed.connect(_on_notification_dismissed)
	_notification_panel.add_child(close_button)

func _process(delta: float) -> void:
	_cooldown = max(_cooldown - delta, 0.0)
	if _message_timer > 0.0:
		_message_timer -= delta
		if _message_timer <= 0.0:
			_message_label.text = ""
	_update_warning_banner()
	_update_notifications()

func _update_notifications() -> void:
	if _pending_notifications.is_empty():
		_pending_notifications.append_array(Stats.consume_notifications())
	if not _notification_panel.visible and not _pending_notifications.is_empty():
		_notification_label.text = _pending_notifications[0]
		_notification_panel.visible = true

func _on_notification_dismissed() -> void:
	if not _pending_notifications.is_empty():
		_pending_notifications.pop_front()
	_notification_panel.visible = false

func _update_warning_banner() -> void:
	match Stats.mood:
		"Sick":
			_warning_label.text = "Your pet is sick! It needs care now."
			_warning_label.visible = true
		"Hungry":
			_warning_label.text = "Your pet is hungry!"
			_warning_label.visible = true
		_:
			_warning_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if _cooldown > 0.0:
		return
	if not (event is InputEventMouseButton and event.pressed):
		return

	var message := _handle_tap(event.position)
	if message != "":
		_show_message(message)
		_cooldown = action_cooldown_seconds

func _show_message(message: String) -> void:
	_message_label.text = message
	_message_timer = 1.6

# Override in subclasses: text shown immediately when the room loads, or "" for none.
func _get_intro_message() -> String:
	return ""

# Override in subclasses: perform the room's action for a tap at `pos` and
# return the feedback message, or "" if the tap didn't hit an actionable spot.
func _handle_tap(_pos: Vector2) -> String:
	return ""
