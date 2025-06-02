extends CharacterBody2D

var evo: int = 0

const SPEED = 50.0

var move: bool = true

var dirArray: Array[int] = [-1, 0, 1]
var timeArray: Array[float] = [0.5, 1.0, 1.5, 2.0]
var direction: int = 0
var time: float = 1

@export var peng_1: AnimatedSprite2D

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta) -> void:
	
	time -= delta
	
	if time <= 0:
		direction = dirArray.pick_random()
		time = timeArray.pick_random()
		print(time)
		print(direction)
	
	if direction > 0:
			animated_sprite.flip_h = true
	elif direction < 0:
		animated_sprite.flip_h = false
	
	if direction:
		velocity.x = direction * SPEED
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
	
func toggle_visibility(object):
	object.visible = !object.visible
	
func _input(event):
	if Input.is_action_just_pressed("evolve"):
		if evo < 3:
			evo += 1
		else:
			evo = 0

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
