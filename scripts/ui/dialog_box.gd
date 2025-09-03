extends Control

func _display_text(text: String):
	$TextOutput.text = text

func _ready():
	size = get_viewport().get_visible_rect().size
