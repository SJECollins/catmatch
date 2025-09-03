extends Node2D

func _ready() -> void:
	# Start the game in the game manager when SceneContainer loads
	var game_manager = $"../GameManager"
	game_manager._on_start_game()
