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
const MAX_BUBBLE_STREAK: int = 99

const MAX_BOUNCE_PITCH: float = 3.5
const MIN_BOUNCE_PITCH: float = 0.35


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

var bubble_streak: int = 0
enum states {
	GROUNDED,
	AIRBORNE,
	DASHING,
	HITSTUN,
	DEAD,
	FULL_DEAD
}

@onready var hitstun_timer = $Timers/Hitstun_Timer
@onready var dash_timer = $Timers/Dash_Timer
@onready var dash_cooldown_timer = $Timers/Dash_Cooldown_Timer
@onready var sprite = $AnimatedSprite2D
@onready var flipping_timer = $Timers/Flipping_Timer
@onready var death_timer = $Timers/Death_Timer
@onready var dash_bar = $dash_bar
@export var ghost_node: PackedScene
@onready var combo_display = $combo_display
#sounds
@onready var jump_1 = $Sounds/Jump_1
@onready var jump_2 = $Sounds/Jump_2
@onready var jump_3 = $Sounds/Jump_3
@onready var dash = $Sounds/Dash
@onready var hit_1 = $Sounds/Hit_1
@onready var hit_2 = $Sounds/Hit_2
@onready var heal = $Sounds/Heal
@onready var on_fire = $on_fire
@onready var music = $Sounds/music
@onready var music_2 = $Sounds/music_2
@onready var music_timer = $Sounds/music_timer

var next_song

func _ready() -> void:
	player_state = states.GROUNDED
	health = 3
	combo_display.visible = false
	jump_3.pitch_scale = MIN_BOUNCE_PITCH
	music.play()
	
func _process(delta) -> void:
	animate()

func _physics_process(delta) -> void:
	if player_state == states.FULL_DEAD:
		velocity.y += delta * FALL_NORMAL_GRAVITY
		velocity.x = move_toward(velocity.x, 0, 20)
		move_and_slide()
	elif dying:
		player_state = states.DEAD
		velocity.x = move_toward(velocity.x, 0, 20)
		velocity.y += delta * FALL_NORMAL_GRAVITY
		move_and_slide()
	else:
		handle_dash()
		handle_gravity(delta)
		handle_jump_buffer(delta)
		handle_jump()
		handle_movement()
		move_and_slide()

func get_gravity() -> float:
	if flipping:
		if velocity.y > 0:
			return RISE_BOUNCE_GRAVITY
		return FALL_BOUNCE_GRAVITY
	if velocity.y > 0:
		return RISE_NORMAL_GRAVITY
	return FALL_NORMAL_GRAVITY

func handle_gravity(delta) -> void:
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
		bubble_streak = 0
		jump_3.pitch_scale = MIN_BOUNCE_PITCH
		jump_time = 0

func handle_jump_buffer(delta) -> void:
	jump_buffer_time_left -= delta
	if Input.is_action_just_pressed("jump"):
		jump_buffer_time_left = JUMP_BUFFER_TIME

func handle_jump() -> void:
	if jump_buffer_time_left > 0:
		if player_state == states.GROUNDED:
			jump_2.play()
			velocity.y = JUMP_VELOCITY
			jump_buffer_time_left = 0
			jump_time = 0
		elif player_state == states.AIRBORNE:
			dash_pressed = true
	else:
		dash_pressed = false

func handle_dash() -> void:
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
		dash.play()
		dash_timer.start()
		dash_cooldown_timer.start()
	
func handle_movement() -> void:
	if player_state == states.DASHING or player_state == states.HITSTUN:
		return
	direction = Input.get_axis("left", "right")
	if is_on_floor():
		velocity.x = direction * GROUND_MOVE_SPEED
	else:
		velocity.x = direction * AIR_MOVE_SPEED

func handle_flip() -> void:
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

func bounce() -> void:
	velocity.y = BOUNCE_VELOCITY
	flipping = true
	jump_3.play()
	jump_3.pitch_scale = 0.032 * bubble_streak + 0.3

func change_health(amount: int) -> void:
	health = min(health + amount, 3)
	get_parent().change_health(health)
	if health <= 0:
		die()

func get_hit(mine_position: Vector2, damage: int) -> void:
	if position.x < mine_position.x:
		velocity.x = -KNOCKBACK_VECTOR.x
	else:
		velocity.x = KNOCKBACK_VECTOR.x
	velocity.y = KNOCKBACK_VECTOR.y
	player_state = states.HITSTUN
	change_health(damage)
	hitstun_timer.start()

func die() -> void:
	dying = true
	if player_state != states.DEAD:
		player_state = states.DEAD
		hit_2.play()
		death_timer.start()
	else:
		pass

func handle_death() -> void:
	player_state = states.FULL_DEAD
	get_parent().game_over()

func add_ghost() -> void:
	var ghost = ghost_node.instantiate()
	ghost.set_property(position, sprite.scale)
	get_tree().current_scene.add_child(ghost)

func animate() -> void:
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
		states.FULL_DEAD:
			sprite.play("dead")
	if can_dash:
		dash_bar.play("nothing")
	else:
		dash_bar.play("loading")
	if bubble_streak < 1:
		combo_display.visible = false
		combo_display.text = ""
	else:
		combo_display.visible = true
		combo_display.text = "+ " + str(bubble_streak)
	if bubble_streak < 30:
		on_fire.play("invisible")
	elif bubble_streak < 60:
		on_fire.play("smoke")
	else:
		on_fire.play("fire")

func _on_death_timer_timeout():
	handle_death()

func _on_flipping_timer_timeout():
	pass # Replace with function body.

func _on_bubble_hitbox_area_entered(area):
	if player_state == states.DASHING or player_state == states.HITSTUN or player_state == states.DEAD or player_state == states.FULL_DEAD:
		return
	if area.is_in_group("platform") and position.y <= area.position.y:
		bounce()
		if area.is_in_group("health"):
			change_health(1)
			heal.play()
		if area.is_in_group("point"):
			#gain a point for bouncing off this
			bubble_streak = min(bubble_streak + 1, MAX_BUBBLE_STREAK)
			update_score(bubble_streak)
		elif area.is_in_group("bonus"):
			if bubble_streak == MAX_BUBBLE_STREAK:
				update_score(bubble_streak * 2)
			elif bubble_streak == 0:
				bubble_streak = 1
				update_score(bubble_streak)
			else:
				bubble_streak = min(bubble_streak * 2, MAX_BUBBLE_STREAK)
				update_score(bubble_streak)
			
		area.pop()
	elif area.is_in_group("trap"):
		get_hit(area.position, -1)
		hit_1.play()
		bubble_streak = 0
		area.pop()

#update the visible score display
func update_score(points: float) -> void:
	get_parent().add_points(bubble_streak)

func _on_dash_timer_timeout():
	if player_state == states.DEAD or player_state == states.FULL_DEAD:
		return #dont undo death
	if is_on_floor():
		player_state = states.GROUNDED
	else:
		player_state = states.AIRBORNE
		flipping = false

func _on_dash_cooldown_timer_timeout():
	can_dash = true

func _on_hitstun_timer_timeout():
	if player_state == states.DEAD or player_state == states.FULL_DEAD:
		return #dont undo death
	if is_on_floor():
		player_state = states.GROUNDED
	else:
		player_state = states.AIRBORNE
		flipping = false

func _on_music_finished():
	music_2.play()

func _on_music_2_finished():
	music.play()
