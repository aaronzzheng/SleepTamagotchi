extends AnimatedSprite2D

const SPEED = 60

var direction = 1
var is_moving = false

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		is_moving = !is_moving  # Toggle moving state
		print("mouse clicked")
		print(is_moving)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_moving:
		direction = 1
		if ray_cast_right.is_colliding():
			direction = -1
			animated_sprite.flip_h = true
		if ray_cast_left.is_colliding():
			direction = 1
			animated_sprite.flip_h = false
		position.x += direction * SPEED * delta
	else:
		direction = 0
		position.x += direction * SPEED * delta
