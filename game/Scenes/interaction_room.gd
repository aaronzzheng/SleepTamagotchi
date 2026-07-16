extends Node2D

var action_cooldown_seconds := 0.6

var _cooldown := 0.0
var _message_timer := 0.0
var _message_label: Label

func _ready() -> void:
	_message_label = Label.new()
	_message_label.position = Vector2(10, 420)
	_message_label.size = Vector2(430, 24)
	_message_label.add_theme_font_size_override("font_size", 14)
	add_child(_message_label)
	var intro := _get_intro_message()
	if intro != "":
		_show_message(intro)

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
