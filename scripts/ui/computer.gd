extends Control

signal try_adoption

@onready var game_manager = get_node("/root/Game/GameManager")
@onready var view_button = $Screen/BtnView
@onready var button_row = $Screen/RowButtons
@onready var no_cat_warning = $Screen/LblNoCats
@onready var screen = $Screen/ScrollContainer/ScreenContainer

var current_cat_index := 0

func _on_btn_select_cat_pressed() -> void:
	game_manager.selected_cat = game_manager.user_cat_data_array[current_cat_index].cat_number
	emit_signal("try_adoption")
	_hide_cat_details()

func _show_details(cat_data):
	$Screen/ScrollContainer/ScreenContainer/RowName/LblName.text = cat_data.name
	$Screen/ScrollContainer/ScreenContainer/RowAgeBreed/LblAge.text = cat_data.age
	$Screen/ScrollContainer/ScreenContainer/RowAgeBreed/LblBreed.text = cat_data.breed
	$Screen/ScrollContainer/ScreenContainer/RowColour/LblColour.text = cat_data.colour
	if cat_data.traits.size() > 0:
		var trait_text = ", ".join(cat_data.traits)
		$Screen/ScrollContainer/ScreenContainer/RowTraits/LblTraits.text = trait_text
	else:
		$Screen/ScrollContainer/ScreenContainer/RowTraits/LblTraits.text = ""

func _on_btn_view_pressed() -> void:
	if game_manager.user_cat_data_array.size() <= 0:
		no_cat_warning.visible = true
	else:
		no_cat_warning.visible = false
		view_button.visible = false
		screen.visible = true
		button_row.visible = true
		current_cat_index = 0
		_show_details(game_manager.user_cat_data_array[current_cat_index])

func _on_btn_left_pressed() -> void:
	if current_cat_index > 0:
		current_cat_index -= 1
	else:
		current_cat_index = game_manager.user_cat_data_array.size() - 1
	_show_details(game_manager.user_cat_data_array[current_cat_index])

func _on_btn_right_pressed() -> void:
	if current_cat_index < game_manager.user_cat_data_array.size() - 1:
		current_cat_index += 1
	else:
		current_cat_index = 0
	_show_details(game_manager.user_cat_data_array[current_cat_index])

func _hide_cat_details() -> void:
	no_cat_warning.visible = false
	button_row.visible = false
	screen.visible = false
	view_button.visible = true
	current_cat_index = 0

func _ready() -> void:
	no_cat_warning.visible = false
	button_row.visible = false
	game_manager.connect("switch_to_kennel", _hide_cat_details)
