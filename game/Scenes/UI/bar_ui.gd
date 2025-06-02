extends Control

@export var health_bar: TextureProgressBar
@export var food_bar: TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	health_bar.value = Stats.health
	food_bar.value = Stats.food
 
