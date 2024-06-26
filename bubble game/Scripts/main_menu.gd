extends Control

const naughty_words: Array = ["fuck", "shit", "bitch", "penis", "cock", "nigga", "nigger", "sh1t", "fxck", "bastard", "dick", "faggot", "pussy", "retard"]
const naughty_words_specific: Array = ["ass", "", "fag", "fagg"]
const BLUE_BUBBLE = preload("res://Scenes/balloon.tscn")
@onready var leaderboard = preload("res://Scenes/leaderboard_new.tscn")
@onready var left_spawntimer = $Spawners/Left_Spawntimer
@onready var right_spawntimer = $Spawners/Right_Spawntimer
@onready var left_one = $Spawners/Left_One
@onready var left_two = $Spawners/Left_Two
@onready var right_one = $Spawners/Right_One
@onready var right_two = $Spawners/Right_Two
@onready var head = $head
@onready var check = $"Enter Name/check"
@onready var check_length_timer = $"Enter Name/check_length_timer"
@onready var start_timer = $Play/start_timer
@onready var line_edit = $"Enter Name/LineEdit"
@onready var music = $music
@onready var music_loop = $music_loop

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var left_bubble
var right_bubble

var leaderboard_node
var name_ok: bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	leaderboard_node = leaderboard.instantiate()
	add_child(leaderboard_node)
	left_spawntimer.wait_time = 1
	right_spawntimer.wait_time = 1
	left_spawntimer.start()
	right_spawntimer.start()
	head.play("visible")
	check.play("invisible")
	music.play()

func check_text(text: String) -> bool:
	text = text.to_lower()
	for word in naughty_words:
		if text.contains(word):
			check.play("wrong")
			check_length_timer.start()
			return false
	for word in naughty_words_specific:
		if text == word:
			check.play("wrong")
			check_length_timer.start()
			return false
	#make this the new name
	leaderboard_node._change_player_name(text)
	check.play("visible")
	check_length_timer.start()
	return true
	
func _on_line_edit_text_submitted(new_text) -> void:
	check_text(new_text)
	


func _on_left_spawntimer_timeout():
	left_bubble = BLUE_BUBBLE.instantiate()
	left_bubble.position = Vector2(rng.randf_range(left_one.position.x, left_two.position.x), 
							rng.randf_range(left_one.position.y, left_two.position.y))
	add_child(left_bubble)
	left_spawntimer.wait_time = rng.randf_range(1, 4)
	left_spawntimer.start()

func _on_right_spawntimer_timeout():
	right_bubble = BLUE_BUBBLE.instantiate()
	right_bubble.position = Vector2(rng.randf_range(right_one.position.x, right_two.position.x), 
							rng.randf_range(right_one.position.y, right_two.position.y))
	add_child(right_bubble)
	right_spawntimer.wait_time = rng.randf_range(1, 4)
	right_spawntimer.start()

func _on_button_pressed():
	check_text(line_edit.text)

func start_game():
	start_timer.start()

func _on_check_length_timeout():
	check.play("invisible")

func _on_start_timer_timeout():
	get_tree().change_scene_to_file("res://Scenes/level_new.tscn")

func _on_music_finished():
	music_loop.start()

func _on_music_loop_timeout():
	music.play()
