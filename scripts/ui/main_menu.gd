extends Control

signal start_game

# Start a new game
func _on_btn_new_pressed() -> void:
	emit_signal("start_game")
