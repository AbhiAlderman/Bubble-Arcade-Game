extends Node2D

const POP_TIME = 0.2
@onready var sprite = $AnimatedSprite2D
var rise_speed: float = -85
var bubble_state: states
var pop_timer: float
var color: String = ""
enum states{
	RISING,
	POPPING
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	match bubble_state:
		states.RISING:
			sprite.play("default: " + color)
		states.POPPING:
			sprite.play("popping: " + color)

func _physics_process(delta) -> void:
	match bubble_state:
		states.RISING:
			position.y += rise_speed * delta
		states.POPPING:
			if pop_timer <= 0:
				queue_free()
			else:
				pop_timer -= delta

func set_green(green: bool) -> void:
	if not green:
		color = ""
	else:
		color = "green"
func set_dark(dark: bool) -> void:
	if not dark:
		color = ""
	else:
		color = "dark"
func pop() -> void:
	bubble_state = states.POPPING
	pop_timer = POP_TIME

func set_rise_speed(speed: float) -> void:
	rise_speed = speed
	
func _on_area_entered(area) -> void:
	if area.is_in_group("skybox"):
		pop()
