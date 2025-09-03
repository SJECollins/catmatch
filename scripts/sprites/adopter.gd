extends Area2D

var adopter_data
var moving = false
@onready var reception = get_node("/root/Game/SceneContainer/Reception")

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		reception.adopter_selected(adopter_data.adopter_number)

func _on_move_to_reception():
	moving = true

func _process(delta):
	if moving:
		global_position = global_position.move_toward(Vector2(900, 256), 100 * delta)
		if global_position.distance_to(Vector2(900, 256)) < 1.0:
			global_position = Vector2(900, 256)
			moving = false

func _ready() -> void:
	if adopter_data:
		$AdopterSprite.texture = adopter_data.texture
