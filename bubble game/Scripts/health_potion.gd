extends RigidBody2D

const GRAVITY = 1200
@onready var lifetime = $area/Lifetime
@onready var despawn_time = $area/Despawn_Time
@onready var sprite = $area/AnimatedSprite2D

var despawning: bool

func _ready() -> void:
	lifetime.start()
	despawning = false
	
func _process(delta) -> void:
	if despawning:
		sprite.play("despawning")
	else:
		sprite.play("default")
		
func _physics_process(delta) -> void:
	linear_velocity.y += delta * GRAVITY
	
func picked_up() -> void:
	queue_free()

func _on_lifetime_timeout():
	despawning = true
	despawn_time.start()


func _on_despawn_time_timeout():
	queue_free()
