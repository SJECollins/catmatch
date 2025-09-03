extends Node2D

@onready var helper_functions = load("res://scripts/helpers/cat_request_generator.gd").new()
@onready var game_manager = get_node("/root/Game/GameManager")
@onready var clipboard = $Clipboard
@onready var form = $Clipboard/ClipboardArea/Form/Column
@export var kennel_scene: PackedScene
@export var highlight_texture: Texture2D
@export var normal_texture: Texture2D

var entered_cat_data := {
	"cat_number": 0,
	"name": "NoName",
	"age": "",
	"breed": "",
	"colour": "",
	"traits": []
}

var created_cats: Array = []
var active_cat = null

# Remove cat sprite
func _clear_cat_sprite(number):
	for child in $CatContainer.get_children():
		if child.cat_data.cat_number == number:
			created_cats.erase(child)
			child.queue_free()
			break

# Create the cat sprites and add to CatContainer
func _create_cats(num_cats: int):
	var cats = game_manager.cat_array
	if created_cats.size() < 10:
		for n in num_cats:
			var new_cat = helper_functions.generate_cat()
			cats.append(new_cat)
			var sprite = kennel_scene.instantiate()
			sprite.cat_data = new_cat
			$CatContainer.add_child(sprite)
			created_cats.append(sprite)
			var new_position = _find_free_position()
			if new_position != Vector2(-1, -1):
				sprite.position = new_position
			else:
				print("No space available for new cat!")
	else:
		print("Too many cats!")

func _find_free_position() -> Vector2:
	var taken_positions := {}
	for new_cat in created_cats:
		taken_positions[new_cat.position] = true
	for row in [128, 384]:
		for col in range(5):
			var pos = Vector2(col * 256, row)
			if not taken_positions.has(pos):
				return pos
	# No free position found
	return Vector2(-1, -1) 


# Select a cat and highlight the kennel
func cat_selected(number):
	# Don't allow selection to change if the clipboard is active!
	if clipboard.active:
		return
	for kennel in created_cats:
		if kennel.cat_data.cat_number == number:
			active_cat = kennel
			var exists: bool = false
			for existing_cat in game_manager.user_cat_data_array:
				if existing_cat.cat_number == active_cat.cat_data.cat_number:
					_set_fields(form, existing_cat)
					exists = true
					break
			if !exists:
				_reset_form_fields()
	if active_cat == null:
		print("Can't find cat")
		return
	highlight_kennel(number)

# Highlight the kennel
func highlight_kennel(number):
	for kennel in created_cats:
		if kennel.cat_data.cat_number == number:
			kennel.get_node("KennelFront").texture = highlight_texture
		else:
			kennel.get_node("KennelFront").texture = normal_texture

# Retrieve value from a field
func _get_value(field, field_name: String):
	var selected_id = field.get_selected_id()
	if selected_id == -1:
		return "No " + field_name + " entered."
	var value = field.get_item_text(field.get_selected_id())
	if value is String and value != "":
		return value
	else:
		return "No " + field_name + " entered."

# Retrieve traits specifically
func _get_traits(field, fieldName):
	var traits = field.selected
	if traits.size() > 0:
		return traits.duplicate()
	else:
		return ["No " + fieldName + " entered."]

# Set a field on the form with existing value
func _set_a_field(field, value):
	for i in field.item_count:
		if field.get_item_text(i) == value:
			field.select(i)
			return

# Set all the form fields for existing cat
func _set_fields(cat_form, data):
	cat_form.get_node("RowName/InputName").text = data.name
	_set_a_field(cat_form.get_node("RowAge/OptionAge"), data.age)
	_set_a_field(cat_form.get_node("RowBreed/OptionBreed"), data.breed)
	_set_a_field(cat_form.get_node("RowColour/OptionColour"), data.colour)
	_set_a_field(cat_form.get_node("RowTraits/OptionTraits"), data.trait)
	#cat_form.get_node("RowTraits/DDTraits").set_selected_by_texts(data.traits)

# Retrieve data from the form fields
func _retrieve_data(cat_form, new_data):
	new_data.cat_number = active_cat.cat_data.cat_number
	if cat_form.get_node("RowName/InputName").get_text() != "":
		new_data.name = cat_form.get_node("RowName/InputName").get_text()
	new_data.age = _get_value(cat_form.get_node("RowAge/OptionAge"), "Age")
	new_data.breed = _get_value(cat_form.get_node("RowBreed/OptionBreed"), "Breed")
	new_data.colour = _get_value(cat_form.get_node("RowColour/OptionColour"), "Colour")
	new_data.traits.append(_get_value(cat_form.get_node("RowTraits/OptionTraits"), "Traits"))
	#new_data.traits = _get_traits(cat_form.get_node("RowTraits/DDTraits"), "Traits")
	return new_data

# Reset the form fields
func _reset_form_fields() -> void:
	form.get_node("RowName/InputName").text = ""
	form.get_node("RowAge/OptionAge").selected = -1
	form.get_node("RowBreed/OptionBreed").selected = -1
	form.get_node("RowColour/OptionColour").selected = -1
	form.get_node("RowTraits/OptionTraits").selected = -1
	#if form.get_node("RowTraits/DDTraits").selected.size() > 0:
		#for checkbox in form.get_node("RowTraits/DDTraits/PopupDropdown/OptionList").get_children():
			#if checkbox.button_pressed:
				#checkbox.button_pressed = false
		#form.get_node("RowTraits/DDTraits").selected.clear()
		#form.get_node("RowTraits/DDTraits").dropdown_button.text = "Select options"

# Save form
func _on_btn_confirm_pressed():
	if active_cat == null:
		print("No cat selected.")
		clipboard._update_status()
	else:
		var new_data = entered_cat_data.duplicate(true)
		var retrieved_data = _retrieve_data(form, new_data)
		for existing_cat in game_manager.user_cat_data_array:
			if existing_cat.cat_number == new_data.cat_number:
				game_manager.user_cat_data_array.erase(existing_cat)
		game_manager.user_cat_data_array.append(retrieved_data)
		_reset_form_fields()

# Clear form
func _on_btn_cancel_pressed() -> void:
	_reset_form_fields()

func _ready() -> void:
	var reception = get_node("/root/Game/SceneContainer/Reception")
	reception.end_day.connect(_create_cats.bind(randi_range(2, 5)))
