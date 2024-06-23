extends Node2D

@onready var left_top = $Left_Top
@onready var left_bottom = $Left_Bottom
@onready var right_top = $Right_Top
@onready var right_bottom = $Right_Bottom
@onready var head_1 = $Life_Heads/head_1
@onready var head_2 = $Life_Heads/head_2
@onready var head_3 = $Life_Heads/head_3
@onready var flash_damage_timer = $Life_Heads/Flash_Damage_Timer

const BLUE_BUBBLE = preload("res://Scenes/balloon.tscn")
const GREEN_BUBBLE = preload("res://Scenes/green_bubble.tscn")
const RED_BUBBLE = preload("res://Scenes/red_bubble.tscn")
const SPAWNRATE: float = 5

# Called when the node enters the scene tree for the first time.
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var random_number: float
var next_bubble
var time: float
var next_spawntime: float
var player_health: int
var flash_damage: bool

func _ready():
	time = 0
	next_spawntime
	player_health = 3
	flash_damage = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if time >= next_spawntime:
		next_spawntime += SPAWNRATE
		random_number = rng.randf_range(1, 8)
		spawn_bubbles_blue()
	time += delta
	match player_health:
		0:
			if flash_damage:
				head_1.play("damaged")
			else:
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
			else:
				head_1.play("visible")
				head_2.play("visible")
				head_3.play("invisible")
		3:
			head_1.play("visible")
			head_2.play("visible")
			head_3.play("visible")

func spawn_bubbles_blue():
	for i in range(random_number):
		next_bubble = BLUE_BUBBLE.instantiate()
		next_bubble.position = Vector2(rng.randf_range(left_top.position.x, right_top.position.x), rng.randf_range(left_top.position.y, left_bottom.position.y))
		add_child(next_bubble)
		
func change_health(health: int):
	if health < player_health:
		flash_damage = true
		flash_damage_timer.start()
	player_health = health


func _on_flash_damage_timer_timeout():
	flash_damage = false
