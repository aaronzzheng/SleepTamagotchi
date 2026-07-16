extends CharacterBody2D

var evo: int = 0

const SPEED = 50.0
const HORIZONTAL_MARGIN = 24.0

var move: bool = true

var dirArray: Array[int] = [-1, 0, 1]
var timeArray: Array[float] = [0.5, 1.0, 1.5, 2.0]
var direction: int = 0
var time: float = 1
var _mood_speed_scale: float = 1.0

@export var peng_1: AnimatedSprite2D

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta) -> void:

	evo = clampi(Stats.completed_quest_count, 0, 3)
	_apply_mood()

	time -= delta

	if time <= 0:
		direction = dirArray.pick_random()
		time = timeArray.pick_random()

	if direction > 0:
			animated_sprite.flip_h = true
	elif direction < 0:
		animated_sprite.flip_h = false
	
	if direction:
		velocity.x = direction * SPEED * _mood_speed_scale
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Play animations
	match evo:
		0:
			if direction == 0:
				animated_sprite.play("idle1")
			else:
				animated_sprite.play("walk1")
		1:
			if direction == 0:
				animated_sprite.play("idle2")
			else:
				animated_sprite.play("walk2")
		2:
			if direction == 0:
				animated_sprite.play("idle3")
			else:
				animated_sprite.play("walk3")
		3:
			if direction == 0:
				animated_sprite.play("idle4")
			else:
				animated_sprite.play("walk4")

	move_and_slide()
	_keep_in_bounds()
	
func toggle_visibility(object):
	object.visible = !object.visible

func _apply_mood() -> void:
	match Stats.mood:
		"Sick":
			animated_sprite.modulate = Color(0.75, 0.75, 0.85)
			animated_sprite.speed_scale = 0.6
			_mood_speed_scale = 0.6
		"Hungry":
			animated_sprite.modulate = Color(1.0, 0.9, 0.8)
			animated_sprite.speed_scale = 0.8
			_mood_speed_scale = 0.8
		"Tired":
			animated_sprite.modulate = Color(0.85, 0.85, 1.0)
			animated_sprite.speed_scale = 0.85
			_mood_speed_scale = 0.85
		_:
			animated_sprite.modulate = Color(1, 1, 1)
			animated_sprite.speed_scale = 1.0
			_mood_speed_scale = 1.0

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _keep_in_bounds() -> void:
	var viewport_size := get_viewport_rect().size
	var left_limit := HORIZONTAL_MARGIN
	var right_limit := viewport_size.x - HORIZONTAL_MARGIN

	if position.x < left_limit:
		position.x = left_limit
		direction = 1
	elif position.x > right_limit:
		position.x = right_limit
		direction = -1
