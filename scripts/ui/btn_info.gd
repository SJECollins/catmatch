extends Button

var show_info: bool = false
@onready var info_panel = $"../InfoPanel"

func _ready() -> void:
	position.x = (get_viewport().get_visible_rect().size).x - size.x


func _on_pressed() -> void:
	if show_info:
		info_panel.visible = false
		show_info = false
	else:
		info_panel.visible = true
		show_info = true


func _on_btn_close_pressed() -> void:
	_on_pressed()
