extends Node2D

const POP_TIME = 0.08
const RISE_SPEED = -120
@onready var sprite = $AnimatedSprite2D
var bubble_state: states
var pop_timer: float
enum states{
	RISING,
	POPPING
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sprite.modulate = Color.html("#72E218")
	match bubble_state:
		states.RISING:
			sprite.play("default")
		states.POPPING:
			sprite.play("popping")

func _physics_process(delta):
	match bubble_state:
		states.RISING:
			position.y += RISE_SPEED * delta
		states.POPPING:
			if pop_timer <= 0:
				queue_free()
			else:
				pop_timer -= delta

func pop():
	bubble_state = states.POPPING
	pop_timer = POP_TIME


func _on_area_entered(area):
	if area.is_in_group("skybox"):
		pop()
