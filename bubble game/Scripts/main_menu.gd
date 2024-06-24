extends Control

const naughty_words: Array = ["fuck", "shit", "bitch", "nigga", "nigger", "sh1t", "fxck", "bastard", "dick", "faggot", "pussy", "retard"]
const naughty_words_specific: Array = ["ass"]
const BLUE_BUBBLE = preload("res://Scenes/balloon.tscn")
@onready var leaderboard = preload("res://Scenes/leaderboard.tscn")
@onready var next_scene = preload("res://Scenes/level.tscn")
@onready var left_spawntimer = $Spawners/Left_Spawntimer
@onready var right_spawntimer = $Spawners/Right_Spawntimer
@onready var left_one = $Spawners/Left_One
@onready var left_two = $Spawners/Left_Two
@onready var right_one = $Spawners/Right_One
@onready var right_two = $Spawners/Right_Two
@onready var head = $head
@onready var check = $"Enter Name/check"
@onready var check_length_timer = $"Enter Name/check_length_timer"

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var left_bubble
var right_bubble

var leaderboard_node
# Called when the node enters the scene tree for the first time.
func _ready():
	leaderboard_node = leaderboard.instantiate()
	add_child(leaderboard_node)
	left_spawntimer.wait_time = 1
	right_spawntimer.wait_time = 1
	left_spawntimer.start()
	right_spawntimer.start()
	head.play("visible")
	check.play("invisible")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func invalid_name():
	#called when a no no word is used
	pass

func taken_name():
	#called when a name is already being used
	pass

func _on_line_edit_text_submitted(new_text):
	new_text = new_text.to_lower()
	for word in naughty_words:
		if new_text.contains(word):
			return
	for word in naughty_words_specific:
		if new_text == word:
			return
	#make this the new name
	leaderboard_node._change_player_name(new_text)
	check.play("visible")
	check_length_timer.start()
	


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
	get_tree().change_scene_to_file("res://Scenes/level.tscn")


func _on_check_length_timeout():
	check.play("invisible")
