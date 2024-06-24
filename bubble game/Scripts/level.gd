extends Node2D

#Wave 0 constants
const W0_DOWNTIME: float = 3
const W0_MIN_BUBBLES: int = 1
const W0_MAX_BUBBLES: int = 1
const W0_MIN_TRAPS: int = 0
const W0_MAX_TRAPS: int = 0
const W0_MIN_CHUNK_SIZE: int = 1
const W0_MAX_CHUNK_SIZE: int = 1
#Wave 1 constants
const W1_DOWNTIME: float = 5
const W1_MIN_BUBBLES: int = 2
const W1_MAX_BUBBLES: int = 5
const W1_MIN_TRAPS: int = 1
const W1_MAX_TRAPS: int = 2
const W1_MIN_CHUNK_SIZE: int = 1
const W1_MAX_CHUNK_SIZE: int = 2
#Wave 2 constants
const W2_DOWNTIME: float = 6
const W2_MIN_BUBBLES: int = 4
const W2_MAX_BUBBLES: int = 8
const W2_MIN_TRAPS: int = 2
const W2_MAX_TRAPS: int = 4
const W2_MIN_CHUNK_SIZE: int = 2
const W2_MAX_CHUNK_SIZE: int = 3
#Wave 3 constants
const W3_DOWNTIME: float = 6
const W3_MIN_BUBBLES: int = 6
const W3_MAX_BUBBLES: int = 10
const W3_MIN_TRAPS: int = 4
const W3_MAX_TRAPS: int = 6
const W3_MIN_CHUNK_SIZE: int = 3
const W3_MAX_CHUNK_SIZE: int = 4
#Wave 4 constants
const W4_DOWNTIME: float = 10
const W4_MIN_BUBBLES: int = 7
const W4_MAX_BUBBLES: int = 12
const W4_MIN_TRAPS: int = 6
const W4_MAX_TRAPS: int = 8
const W4_MIN_CHUNK_SIZE: int = 4
const W4_MAX_CHUNK_SIZE: int = 5
#Wave 5 constants
const W5_DOWNTIME: float = 10
const W5_MIN_BUBBLES: int = 8
const W5_MAX_BUBBLES: int = 15
const W5_MIN_TRAPS: int = 8
const W5_MAX_TRAPS: int = 12
const W5_MIN_CHUNK_SIZE: int = 5
const W5_MAX_CHUNK_SIZE: int = 6
#Wave 6 constants
const W6_DOWNTIME: float = 10
const W6_MIN_BUBBLES: int = 11
const W6_MAX_BUBBLES: int = 20
const W6_MIN_TRAPS: int = 12
const W6_MAX_TRAPS: int = 16
const W6_MIN_CHUNK_SIZE: int = 6
const W6_MAX_CHUNK_SIZE: int = 7
#Wave 7 constants
const W7_DOWNTIME: float = 10
const W7_MIN_BUBBLES: int = 15
const W7_MAX_BUBBLES: int = 25
const W7_MIN_TRAPS: int = 20
const W7_MAX_TRAPS: int = 30
const W7_MIN_CHUNK_SIZE: int = 7
const W7_MAX_CHUNK_SIZE: int = 8
#Wave max constants
const WMAX_DOWNTIME: float = 10
const WMAX_MIN_BUBBLES: int = 20
const WMAX_MAX_BUBBLES: int = 35
const WMAX_MIN_TRAPS: int = 30
const WMAX_MAX_TRAPS: int = 40
const WMAX_MIN_CHUNK_SIZE: int = 8
const WMAX_MAX_CHUNK_SIZE: int = 10

const HEALTH_RATE:float = 0.02
const GOLD_RATE: float = 0.01
const GREEN_RATE: float = 0.3
const MISSILE_RATE: float = 0.15
const RED_RATE: float = 0.2
const LAYER_SIZE: int = 200

#load necessary nodes
#spawning markers
@onready var top_right = $Spawning/Top_Right
@onready var top_left = $Spawning/Top_Left
@onready var bounce_left_bottom = $Spawning/Bounce_Left_Bottom
@onready var bounce_left_top = $Spawning/Bounce_Left_Top
@onready var bounce_right_top = $Spawning/Bounce_Right_Top
@onready var bounce_right_bottom = $Spawning/Bounce_Right_Bottom

#other
@onready var head_1 = $Life_Heads/head_1
@onready var head_2 = $Life_Heads/head_2
@onready var head_3 = $Life_Heads/head_3
@onready var flash_damage_timer = $Life_Heads/Flash_Damage_Timer
@onready var wave_downtime = $Spawning/Wave_Downtime
@onready var flash_heal_timer = $Life_Heads/Flash_Heal_Timer
@onready var score_display = $UI/Score_Display
@onready var leaderboard = $leaderboard
@onready var board_display = $UI/Board_Display
@onready var play_again = $UI/play_again
@onready var player = $player

const BLUE_BUBBLE = preload("res://Scenes/balloon.tscn")
const RED_BUBBLE = preload("res://Scenes/red_bubble.tscn")
const MINE_BUBBLE = preload("res://Scenes/mine.tscn")
const GOLD_BUBBLE = preload("res://Scenes/gold_bubble.tscn")
const HEALTH_BUBBLE = preload("res://Scenes/health_bubble.tscn")
const MISSILE = preload("res://Scenes/missile.tscn")

const INIT_DOWNTIME: float = 3

#variables
#player variables
var player_health: int
var flash_damage: bool
var flash_heal: bool
var score: float
#spawning variables
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var next_bubble: Area2D
var wave_number: int
var num_bubbles: int
var num_traps: int
var current_min_bubbles: int
var current_max_bubbles: int
var current_min_traps: int
var current_max_traps: int
var current_wave_downtime: float
var current_top_range: float
var current_bottom_range: float
var current_chunk_min: int
var current_chunk_max: int
var current_bubble_chunk_size: int
var current_trap_chunk_size: int
var bubble_count: int
var trap_count: int
var bubble_threshold: int
var trap_threshold: int
var gold_spawn_chance: float
var health_spawn_chance: float
var green_spawn_chance: float
var missile_spawn_chance: float
var red_spawn_chance: float

func _ready():
	player_health = 3
	flash_damage = false
	flash_heal = false
	wave_number = -1
	wave_downtime.wait_time = INIT_DOWNTIME
	wave_downtime.start()
	score = 0
	score_display.text = "SCORE: " + str(score)
	board_display.visible = false
	play_again.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if play_again.visible == true:
		if Input.is_action_pressed("jump"):
			get_tree().reload_current_scene()

func _process(_delta):
	score_display.text = "SCORE: " + str(score)
	match player_health:
		0:
			head_1.play("invisible")
			head_2.play("invisible")
			head_3.play("invisible")
		1:
			if flash_damage:
				head_1.play("damaged")
				head_2.play("damaged")
			else:
				head_1.play("visible")
				head_2.play("invisible")
			head_3.play("invisible")
		2:
			if flash_damage:
				head_1.play("damaged")
				head_2.play("damaged")
				head_3.play("damaged")
			elif flash_heal:
				head_1.play("healing")
				head_2.play("healing")
				head_3.play("invisible")
			else:
				head_1.play("visible")
				head_2.play("visible")
				head_3.play("invisible")
		3:
			if flash_heal:
				head_1.play("healing")
				head_2.play("healing")
				head_3.play("healing")
			else:
				head_1.play("visible")
				head_2.play("visible")
				head_3.play("visible")

func change_health(health: int):
	if health < player_health:
		flash_damage = true
		flash_damage_timer.start()
	elif health > player_health:
		flash_heal = true
		flash_heal_timer.start()
	player_health = health

func game_over():
	#add score to leaderboard
	#load leaderboard on screen
	#add retry button (pressing space)
	print("CALLED GET LEADERBOARDS")
	leaderboard._upload_score(score)
	

func grab_leaderboard():
	leaderboard._get_leaderboards()
	print("BACK FROM LEADERBOARDS")
	


func display_leaderboard(leaderboard: String):
	board_display.visible = true
	board_display.display_scores(leaderboard)
	play_again.visible = true
	
	
func spawn_wave():
	match wave_number:
		0:
			current_wave_downtime = W0_DOWNTIME
			current_min_bubbles = W0_MIN_BUBBLES
			current_max_bubbles = W0_MAX_BUBBLES
			current_min_traps = W0_MIN_TRAPS
			current_max_traps = W0_MAX_TRAPS
			current_chunk_min = W0_MIN_CHUNK_SIZE
			current_chunk_max = W0_MAX_CHUNK_SIZE
			gold_spawn_chance = 0
			health_spawn_chance = 0
			missile_spawn_chance = 0
			red_spawn_chance = 0
			green_spawn_chance = 0
		1:
			current_min_bubbles = W1_MIN_BUBBLES
			current_max_bubbles = W1_MAX_BUBBLES
			current_min_traps = W1_MIN_TRAPS
			current_max_traps = W1_MAX_TRAPS
			current_wave_downtime = W1_DOWNTIME
			current_chunk_min = W1_MIN_CHUNK_SIZE
			current_chunk_max = W1_MAX_CHUNK_SIZE
			gold_spawn_chance = 0
			health_spawn_chance = 0
			missile_spawn_chance = 0
			red_spawn_chance = 0
			green_spawn_chance = 0
			
		2:
			current_min_bubbles = W2_MIN_BUBBLES
			current_max_bubbles = W2_MAX_BUBBLES
			current_min_traps = W2_MIN_TRAPS
			current_max_traps = W2_MAX_TRAPS
			current_wave_downtime = W2_DOWNTIME
			current_chunk_min = W2_MIN_CHUNK_SIZE
			current_chunk_max = W2_MAX_CHUNK_SIZE
			gold_spawn_chance = GOLD_RATE
			health_spawn_chance = HEALTH_RATE
			missile_spawn_chance = MISSILE_RATE
			red_spawn_chance = RED_RATE
			green_spawn_chance = GREEN_RATE
		3:
			current_min_bubbles = W3_MIN_BUBBLES
			current_max_bubbles = W3_MAX_BUBBLES
			current_min_traps = W3_MIN_TRAPS
			current_max_traps = W3_MAX_TRAPS
			current_wave_downtime = W3_DOWNTIME
			current_chunk_min = W3_MIN_CHUNK_SIZE
			current_chunk_max = W3_MAX_CHUNK_SIZE
		4:
			current_min_bubbles = W4_MIN_BUBBLES
			current_max_bubbles = W4_MAX_BUBBLES
			current_min_traps = W4_MIN_TRAPS
			current_max_traps = W4_MAX_TRAPS
			current_wave_downtime = W4_DOWNTIME
			current_chunk_min = W4_MIN_CHUNK_SIZE
			current_chunk_max = W4_MAX_CHUNK_SIZE
		5:
			current_min_bubbles = W5_MIN_BUBBLES
			current_max_bubbles = W5_MAX_BUBBLES
			current_min_traps = W5_MIN_TRAPS
			current_max_traps = W5_MAX_TRAPS
			current_wave_downtime = W5_DOWNTIME
			current_chunk_min = W5_MIN_CHUNK_SIZE
			current_chunk_max = W5_MAX_CHUNK_SIZE
		6:
			current_min_bubbles = W6_MIN_BUBBLES
			current_max_bubbles = W6_MAX_BUBBLES
			current_min_traps = W6_MIN_TRAPS
			current_max_traps = W6_MAX_TRAPS
			current_wave_downtime = W6_DOWNTIME
			current_chunk_min = W6_MIN_CHUNK_SIZE
			current_chunk_max = W6_MAX_CHUNK_SIZE
			gold_spawn_chance *= 2
			health_spawn_chance *= 2
			missile_spawn_chance *= 2
			red_spawn_chance *= 2
			green_spawn_chance *= 2
		7:
			current_min_bubbles = W7_MIN_BUBBLES
			current_max_bubbles = W7_MAX_BUBBLES
			current_min_traps = W7_MIN_TRAPS
			current_max_traps = W7_MAX_TRAPS
			current_wave_downtime = W7_DOWNTIME
			current_chunk_min = W7_MIN_CHUNK_SIZE
			current_chunk_max = W7_MAX_CHUNK_SIZE
		_:
			current_min_bubbles = WMAX_MIN_BUBBLES
			current_max_bubbles = WMAX_MAX_BUBBLES
			current_min_traps = WMAX_MIN_TRAPS
			current_max_traps = WMAX_MAX_TRAPS
			current_wave_downtime = WMAX_DOWNTIME
			current_chunk_min = WMAX_MIN_CHUNK_SIZE
			current_chunk_max = WMAX_MAX_CHUNK_SIZE
	run_wave()
		

func run_wave():
	num_bubbles = rng.randi_range(current_min_bubbles, current_max_bubbles)
	num_traps = rng.randi_range(current_min_traps, current_max_traps)
	current_top_range = top_left.position.y
	current_bottom_range = current_top_range + LAYER_SIZE
	current_bubble_chunk_size = rng.randi_range(current_chunk_min, current_chunk_max)
	current_trap_chunk_size = rng.randi_range(current_chunk_min, current_chunk_max)
	wave_downtime.wait_time = current_wave_downtime
	bubble_count = 0
	trap_count = 0
	bubble_threshold = bubble_count + current_bubble_chunk_size
	trap_threshold = trap_count + current_trap_chunk_size
	var change_range: bool = false
	while(bubble_count < num_bubbles or trap_count < num_traps):
		if bubble_count >= bubble_threshold:
			current_bubble_chunk_size = rng.randi_range(current_chunk_min, current_chunk_max)
			bubble_threshold = bubble_count + current_bubble_chunk_size
			change_range = true
		if trap_count >= trap_threshold:
			current_trap_chunk_size = rng.randi_range(current_chunk_min, current_chunk_max)
			trap_threshold = trap_count + current_trap_chunk_size
			change_range = true
		if change_range:
			current_top_range = current_bottom_range
			current_bottom_range = current_top_range + LAYER_SIZE
			change_range = false
		if bubble_count < num_bubbles:
			create_props(current_bubble_chunk_size, false, current_top_range, current_bottom_range)
			bubble_count += current_bubble_chunk_size
		if trap_count < num_traps:
			create_props(current_trap_chunk_size, true, current_top_range, current_bottom_range)
			trap_count += current_trap_chunk_size
	wave_downtime.start()			

func create_props(amount: int, trap: bool, top_range: float, bottom_range: float):
	for i in range(amount):
		if trap:
			var missile_chance = rng.randf_range(0.0001, 1)
			if missile_chance < missile_spawn_chance:
				#spawn missile
				next_bubble = MISSILE.instantiate()
			elif missile_chance <= missile_spawn_chance + red_spawn_chance:
				#spawn red bubble
				next_bubble = RED_BUBBLE.instantiate()
				var left_chance = rng.randf_range(0, 1)
				if left_chance < 0.5:
					next_bubble.position = Vector2(rng.randf_range(bounce_left_bottom.position.x, bounce_left_top.position.y),
						rng.randf_range(bounce_left_top.position.y, bounce_left_bottom.position.y))
					next_bubble.set_move_speed(rng.randf_range(90, 110))
				else:
					next_bubble.position = Vector2(rng.randf_range(bounce_right_bottom.position.x, bounce_right_top.position.x), 
						rng.randf_range(bounce_right_top.position.y, bounce_right_bottom.position.y))
					next_bubble.set_move_speed(rng.randf_range(-110, -90))
				add_child(next_bubble)
				return
			else:
				next_bubble = MINE_BUBBLE.instantiate()
		else:
			var bubble_chance = rng.randf_range(0.001, 1)
			if bubble_chance < gold_spawn_chance:
				#spawn gold bubble
				next_bubble = GOLD_BUBBLE.instantiate()
			elif bubble_chance < health_spawn_chance + gold_spawn_chance:
				#spawn health bubble
				next_bubble = HEALTH_BUBBLE.instantiate()
			elif bubble_chance < health_spawn_chance + gold_spawn_chance + green_spawn_chance:
				#50% GREEN, 50% DARK
				bubble_chance = rng.randf_range(0, 1)
				if bubble_chance < 0.5:
					#spawn green bubble
					next_bubble = BLUE_BUBBLE.instantiate()
					next_bubble.set_green(true)
					next_bubble.set_rise_speed(rng.randf_range(-110, -130))
				else:
					#spawn dark bubble
					next_bubble = BLUE_BUBBLE.instantiate()
					next_bubble.set_dark(true)
					next_bubble.set_rise_speed(rng.randf_range(-50, -70))
			else:
				#spawn blue bubble
				next_bubble = BLUE_BUBBLE.instantiate()
				next_bubble.set_green(false)
				next_bubble.set_rise_speed(rng.randf_range(-80, -90))
		next_bubble.position = Vector2(
			rng.randf_range(top_left.position.x, top_right.position.x), rng.randf_range(top_range, bottom_range))
		add_child(next_bubble)

func add_points(points: float):
	score += points
	
func _on_flash_damage_timer_timeout():
	flash_damage = false


func _on_wave_downtime_timeout():
	wave_number += 1
	spawn_wave()


func _on_flash_heal_timer_timeout():
	flash_heal = false
