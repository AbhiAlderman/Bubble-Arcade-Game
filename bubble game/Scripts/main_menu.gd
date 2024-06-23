extends Control

const naughty_words: Array = ["fuck", "shit", "bitch", "nigga", "nigger", "sh1t", "fxck", "bastard"]
const naughty_words_specific: Array = ["ass"]
@onready var leaderboard = $leaderboard

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
			invalid_name()
			return
	for word in naughty_words_specific:
		if new_text == word:
			invalid_name()
			return
	#make this the new name
	leaderboard._change_player_name(new_text)
