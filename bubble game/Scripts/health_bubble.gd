extends Node2D

const POP_TIME = 0.2
@onready var sprite = $AnimatedSprite2D
@export var health_node: PackedScene

var rise_speed: float = -80
var bubble_state: states
var pop_timer: float
enum states{
	RISING,
	POPPING
}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	match bubble_state:
		states.RISING:
			sprite.play("default")
		states.POPPING:
			sprite.play("popping")

func _physics_process(delta) -> void:
	match bubble_state:
		states.RISING:
			position.y += rise_speed * delta
		states.POPPING:
			if pop_timer <= 0:
				queue_free()
			else:
				pop_timer -= delta

func pop() -> void:
	bubble_state = states.POPPING
	pop_timer = POP_TIME

func set_rise_speed(speed: float) -> void:
	rise_speed = speed
	
func _on_area_entered(area) -> void:
	if area.is_in_group("skybox"):
		pop()
