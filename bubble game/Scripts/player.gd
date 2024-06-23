extends CharacterBody2D

#constants
#movement
const GROUND_MOVE_SPEED: float = 350
const AIR_MOVE_SPEED: float = 350
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
#dashing
const DASH_SPEED:float = 700
const DASH_COOLDOWN_TIME: float = 3
const KNOCKBACK_VECTOR: Vector2 = Vector2(400, -400)

var can_dash = true
var jump_buffer_time_left: float = 0.0
var jump_time: float = 0.0
var dying: bool = false
var flipping: bool = false
var player_state: states
var direction: float = 0.0
var dash_aim_x: float #where dash is aiming based on wasd
var dash_aim_y: float
var dash_pressed: bool = false
var health: int
enum states {
	GROUNDED,
	AIRBORNE,
	DASHING,
	HITSTUN,
	DEAD
}

@onready var hitstun_timer = $Timers/Hitstun_Timer
@onready var dash_timer = $Timers/Dash_Timer
@onready var dash_cooldown_timer = $Timers/Dash_Cooldown_Timer
@onready var sprite = $AnimatedSprite2D
@onready var flipping_timer = $Timers/Flipping_Timer
@onready var death_timer = $Timers/Death_Timer
@onready var dash_bar = $dash_bar
@export var ghost_node: PackedScene

func _ready():
	player_state = states.GROUNDED
	health = 3
	change_health(0)
func _process(delta):
	animate()

func _physics_process(delta):
	if dying:
		player_state = states.DEAD
		velocity.y += delta * FALL_NORMAL_GRAVITY
		move_and_slide()
	else:
		handle_dash()
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
	if player_state == states.DASHING:
		return
	if not is_on_floor():
		if player_state == states.HITSTUN:
			velocity.y += get_gravity() * delta
			return
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
	if jump_buffer_time_left > 0:
		if player_state == states.GROUNDED:
			velocity.y = JUMP_VELOCITY
			jump_buffer_time_left = 0
			jump_time = 0
		elif player_state == states.AIRBORNE:
			dash_pressed = true
	else:
		dash_pressed = false

func handle_dash():
	if (Input.is_action_pressed("dash") or dash_pressed) and can_dash and player_state != states.HITSTUN:
		player_state = states.DASHING
		can_dash = false
		dash_aim_x = Input.get_axis("left", "right")
		dash_aim_y = Input.get_axis("up", "down")
		velocity.x = dash_aim_x * DASH_SPEED
		velocity.y = dash_aim_y * DASH_SPEED
		if velocity.x != 0 and velocity.y != 0:
			velocity.x *= 0.7
			velocity.y *= 0.7
		else:
			velocity.x *= 0.9
			velocity.y *= 0.9
		dash_timer.start()
		dash_cooldown_timer.start()
	
func handle_movement():
	if player_state == states.DASHING or player_state == states.HITSTUN:
		return
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

func change_health(amount: int):
	health = min(health + amount, 3)
	get_parent().change_health(health)
	if health <= 0:
		die()

func get_hit(mine_position: Vector2, damage: int):
	if position.x < mine_position.x:
		velocity.x = -KNOCKBACK_VECTOR.x
	else:
		velocity.x = KNOCKBACK_VECTOR.x
	velocity.y = KNOCKBACK_VECTOR.y
	player_state = states.HITSTUN
	change_health(damage)
	hitstun_timer.start()

func die():
	dying = true
	if player_state != states.DEAD:
		player_state = states.DEAD
		death_timer.start()
	else:
		pass

func handle_death():
	get_tree().reload_current_scene()

func add_ghost():
	var ghost = ghost_node.instantiate()
	ghost.set_property(position, sprite.scale)
	get_tree().current_scene.add_child(ghost)

func animate():
	match player_state:
		states.GROUNDED:
			handle_flip()
			if velocity.x == 0:
				sprite.play("idle")
			else:
				sprite.play("run")
		states.AIRBORNE:
			handle_flip()
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
		states.DASHING:
			handle_flip()
			sprite.play("dash")
			add_ghost()
		states.HITSTUN:
			sprite.play("hit_stun")
		states.DEAD:
			sprite.play("death")
	if can_dash:
		dash_bar.play("nothing")
	else:
		dash_bar.play("loading")
			
func _on_death_timer_timeout():
	handle_death()


func _on_flipping_timer_timeout():
	pass # Replace with function body.



func _on_bubble_hitbox_area_entered(area):
	if player_state == states.DASHING or player_state == states.HITSTUN:
		return
	if area.is_in_group("platform") and position.y <= area.position.y:
		bounce()
		area.pop()
	elif area.is_in_group("trap"):
		get_hit(area.position, -1)
		area.pop()
		

func _on_dash_timer_timeout():
	if player_state == states.DEAD:
		return #dont undo death
	if is_on_floor():
		player_state = states.GROUNDED
	else:
		player_state = states.AIRBORNE
		flipping = false


func _on_dash_cooldown_timer_timeout():
	can_dash = true


func _on_hitstun_timer_timeout():
	if player_state == states.DEAD:
		return #dont undo death
	if is_on_floor():
		player_state = states.GROUNDED
	else:
		player_state = states.AIRBORNE
		flipping = false
