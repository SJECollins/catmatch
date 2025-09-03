extends Node

var menu_scene = null

# Instantiate the main menu in _ready
func _ready() -> void:
	menu_scene = preload("res://scene/ui/main_menu.tscn").instantiate()
	add_child(menu_scene)
	menu_scene.connect("start_game", _on_start_game)

# When game starts (button clicked) remove menu and change to game scene
func _on_start_game():
	if menu_scene:
		menu_scene.queue_free()
		menu_scene = null
		get_tree().change_scene_to_file("res://scene/game/game.tscn")
