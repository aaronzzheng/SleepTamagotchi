extends CharacterBody2D

const SPEED = 60
var direction := 1
var is_moving := true

@onready var sprite := $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if is_moving:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0

	move_and_slide()

	sprite.flip_h = direction == -1

	var tex = sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
	if tex:
		var half_width = tex.get_width() / 2
		var screen_width = get_viewport_rect().size.x

		if global_position.x >= screen_width - half_width:
			direction = -1
		elif global_position.x <= half_width:
			direction = 1

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		is_moving = !is_moving
		print("Clicked on mochi!")
