extends Control

@onready var leaderboard_names = $Leaderboard_Names

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func display_scores(leaderboard: String):
	leaderboard_names.text = leaderboard
	
