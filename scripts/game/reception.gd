extends Node2D

signal end_day

@onready var helper_functions = load("res://scripts/helpers/cat_request_generator.gd").new()
@onready var game_manager = get_node("/root/Game/GameManager")
@export var adopter_scene: PackedScene

var created_adopters: Array = []
var active_adopter = null

# Create adopters and add them to the PeopleContainer
func _create_adopters(num_adopters: int) -> void:
	var adopters = game_manager.adopter_array
	for n in num_adopters:
		var new_adopter = helper_functions.generate_adopter()
		adopters.append(new_adopter)
		var sprite = adopter_scene.instantiate()
		sprite.adopter_data = new_adopter
		$PeopleContainer.add_child(sprite)
		created_adopters.append(sprite)
	_next_adopter(null)

# Select the adopter and display their request
func adopter_selected(number):
	var selected_adopter
	for ad in created_adopters:
		if ad.adopter_data.adopter_number == number:
			active_adopter = number
			selected_adopter = ad
	if active_adopter == null:
		return
	$DialogBox._display_text(selected_adopter.adopter_data.request)

# Remove the adopter sprite from PeopleContainer
func _remove_adopter_sprite(number):
	for child in $PeopleContainer.get_children():
		if child.adopter_data.adopter_number == number:
			created_adopters.erase(child)
			child.queue_free()
			active_adopter = null
			break

# Remove previous adopter and get next one moving
func _next_adopter(number):
	if number != null:
		_remove_adopter_sprite(number)
	if created_adopters.size() > 0:
		created_adopters[0]._on_move_to_reception()
	else:
		$DialogBox._display_text("There are no more adopters!")
		await get_tree().create_timer(1.0).timeout
		$DialogBox._display_text("New day...")
		_create_adopters(randi_range(2, 6))
		emit_signal("end_day")
