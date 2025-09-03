extends Sprite2D

var cat_data

func _ready() -> void:
	if cat_data:
		texture = cat_data.texture
