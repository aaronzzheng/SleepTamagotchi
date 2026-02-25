extends AnimatedSprite2D

const SPEED = 60
const HORIZONTAL_MARGIN = 20.0

var direction = 1
var is_moving = false

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		is_moving = !is_moving

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_moving:
		direction = 1
		if ray_cast_right.is_colliding():
			direction = -1
			flip_h = true
		if ray_cast_left.is_colliding():
			direction = 1
			flip_h = false
		position.x += direction * SPEED * delta
	else:
		direction = 0
		position.x += direction * SPEED * delta

	_keep_in_bounds()

func _keep_in_bounds() -> void:
	var viewport_size := get_viewport_rect().size
	var left_limit := HORIZONTAL_MARGIN
	var right_limit := viewport_size.x - HORIZONTAL_MARGIN

	if position.x < left_limit:
		position.x = left_limit
		direction = 1
		flip_h = false
	elif position.x > right_limit:
		position.x = right_limit
		direction = -1
		flip_h = true
