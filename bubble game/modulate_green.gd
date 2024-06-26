extends AnimatedSprite2D
@onready var sprite = $"."



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sprite.modulate = Color.html("#72E218")
