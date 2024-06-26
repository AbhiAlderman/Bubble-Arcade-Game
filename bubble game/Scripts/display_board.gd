extends Control

@onready var leaderboard_names = $Leaderboard_Names

func display_scores(leaderboard: String) -> void:
	leaderboard_names.text = leaderboard
	
