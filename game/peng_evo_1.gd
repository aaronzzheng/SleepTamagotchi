extends CharacterBody2D

var evo: int = 0

const SPEED = 100.0
const JUMP_VELOCITY = -250.0

@export var peng_1: AnimatedSprite2D

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
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
		
