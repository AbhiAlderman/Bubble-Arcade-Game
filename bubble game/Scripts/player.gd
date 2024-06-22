extends CharacterBody2D

#constants
#movement
const GROUND_MOVE_SPEED: float = 550
const AIR_MOVE_SPEED: float = 550
#jumping
const JUMP_VELOCITY: float = -500.0
const BOUNCE_VELOCITY: float = -700.0
const RISE_NORMAL_GRAVITY: float = 1600
const FALL_NORMAL_GRAVITY: float = 2200
const RISE_BOUNCE_GRAVITY: float = 1400
const FALL_BOUNCE_GRAVITY: float = 1700
const JUMP_HOLD_GRAVITY: float = 600
const JUMP_BUFFER_TIME: float = 0.15
const JUMP_HOLD_TIME: float = 0.2

var jump_buffer_time_left: float = 0.0
var jump_time: float = 0.0
var dying: bool = false
var flipping: bool = false
var player_state: states
var direction: float = 0.0
var invincible: bool = false
enum states {
	GROUNDED,
	AIRBORNE,
	DEAD
}

@onready var sprite = $AnimatedSprite2D
@onready var flipping_timer = $Timers/Flipping_Timer
@onready var death_timer = $Timers/Death_Timer

func _ready():
	player_state = states.GROUNDED

func _process(_delta):
	animate()

func _physics_process(delta):
	if dying:
		player_state = states.DEAD
	else:
		handle_gravity(delta)
		handle_jump_buffer(delta)
		handle_jump()
		handle_movement()
		move_and_slide()

func get_gravity():
	if flipping:
		if velocity.y > 0:
			return RISE_BOUNCE_GRAVITY
		return FALL_BOUNCE_GRAVITY
	if velocity.y > 0:
		return RISE_NORMAL_GRAVITY
	return FALL_NORMAL_GRAVITY

func handle_gravity(delta):
	if not is_on_floor():
		player_state = states.AIRBORNE
		if Input.is_action_pressed("jump") and jump_time < JUMP_HOLD_TIME and velocity.y < 0:
			jump_time += delta
			velocity.y += JUMP_HOLD_GRAVITY * delta
			player_state = states.AIRBORNE
		else:
			velocity.y += get_gravity() * delta
	else:
		flipping = false
		player_state = states.GROUNDED
		jump_time = 0

func handle_jump_buffer(delta):
	jump_buffer_time_left -= delta
	if Input.is_action_just_pressed("jump"):
		jump_buffer_time_left = JUMP_BUFFER_TIME

func handle_jump():
	if jump_buffer_time_left > 0 and player_state == states.GROUNDED:
		velocity.y = JUMP_VELOCITY
		jump_buffer_time_left = 0
		jump_time = 0

func handle_movement():
	direction = Input.get_axis("left", "right")
	if is_on_floor():
		velocity.x = direction * GROUND_MOVE_SPEED
	else:
		velocity.x = direction * AIR_MOVE_SPEED

func handle_flip():
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

func bounce():
	velocity.y = BOUNCE_VELOCITY
	flipping = true
	
func die():
	if invincible:
		return
	dying = true
	if player_state != states.DEAD:
		player_state = states.DEAD
		death_timer.start()
	else:
		pass

func handle_death():
	get_tree().reload_current_scene()

func animate():
	handle_flip()
	match player_state:
		states.GROUNDED:
			if velocity.x == 0:
				sprite.play("idle")
			else:
				sprite.play("run")
		states.AIRBORNE:
			if velocity.y < 0:
				if flipping:
					sprite.play("flipping")
				else:
					sprite.play("jump_up")
			elif velocity.y > 0:
				if flipping:
					sprite.play("flip_down")
				else:
					sprite.play("jump_down")
			else:
				if flipping:
					sprite.play("flip_peak")
				else:
					sprite.play("jump_peak")
		states.DEAD:
			sprite.play("death")
			
func _on_death_timer_timeout():
	handle_death()


func _on_flipping_timer_timeout():
	pass # Replace with function body.



func _on_bubble_hitbox_area_entered(area):
	if area.is_in_group("platform"):
		if position.y <= area.position.y:
			bounce()
			area.pop()
