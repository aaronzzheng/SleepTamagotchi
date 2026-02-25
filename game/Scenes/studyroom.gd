extends Node2D

const ACTION_COOLDOWN_SECONDS := 0.6

var _cooldown := 0.0
var _message_timer := 0.0
var _message_label: Label

func _ready() -> void:
	_message_label = Label.new()
	_message_label.position = Vector2(10, 420)
	_message_label.size = Vector2(430, 24)
	_message_label.add_theme_font_size_override("font_size", 14)
	add_child(_message_label)
	_show_message("Tap anywhere to study")

func _process(delta: float) -> void:
	_cooldown = max(_cooldown - delta, 0.0)
	if _message_timer > 0.0:
		_message_timer -= delta
		if _message_timer <= 0.0:
			_message_label.text = ""

func _unhandled_input(event: InputEvent) -> void:
	if _cooldown > 0.0:
		return
	if not (event is InputEventMouseButton and event.pressed):
		return

	_show_message(Stats.perform_study())
	_cooldown = ACTION_COOLDOWN_SECONDS

func _show_message(message: String) -> void:
	_message_label.text = message
	_message_timer = 1.6
