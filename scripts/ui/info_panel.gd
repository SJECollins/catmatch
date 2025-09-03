extends Control

func _ready() -> void:
	visible = false
	var viewport_size = get_viewport().get_visible_rect().size
	position.x = (viewport_size.x - size.x)
