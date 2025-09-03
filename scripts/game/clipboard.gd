extends Control

var active := false

func _update_status():
	if active:
		position = Vector2(180, 760)
		scale = Vector2(1,1)
		await get_tree().create_timer(0.2).timeout
		active = false
	else:
		position = Vector2(320, 420)
		scale = Vector2(2,2)
		active = true

func _ready():
	var clipboard_area = $ClipboardArea
	clipboard_area.connect("clipboard_clicked", _update_status)
