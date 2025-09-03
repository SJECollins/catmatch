extends Control

class_name MultiSelectDropdown

@onready var dropdown_button: Button = $BtnDropdown
@onready var popup: PopupPanel = $PopupDropdown
@onready var option_list: VBoxContainer = $PopupDropdown/OptionList

@export var options: Array[String] = []
@export var selected: Array[String] = []

func _ready() -> void:
	dropdown_button.text = "Select options"
	dropdown_button.pressed.connect(_on_dropdown_pressed)
	dropdown_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dropdown_button.clip_contents = true 
	build_checkboxes()

func build_checkboxes() -> void:
	# Clear existing children
	for child in option_list.get_children():
		child.queue_free()
	
	for opt in options:
		var cb = CheckBox.new()
		cb.text = opt
		cb.set_pressed(false)
		cb.toggled.connect(_on_option_toggled.bind(opt))
		option_list.add_child(cb)
	
	# Wait a frame for children to be added properly
	await get_tree().process_frame
	update_popup_size()

func update_popup_size() -> void:
	# Use size instead of rect_size for Godot 4
	var content_size = option_list.get_combined_minimum_size()
	var button_size = dropdown_button.size
	
	# Make sure popup is at least as wide as the button
	var width = max(button_size.x, content_size.x + 20) # Add some padding
	var height = clamp(content_size.y + 10, 50, 300) # Add padding and set minimum height
	
	popup.size = Vector2(width, height)
	
	# Set the VBoxContainer's custom_minimum_size instead
	option_list.custom_minimum_size = Vector2(width - 10, 0)

func _on_dropdown_pressed() -> void:
	update_popup_size() # Update size before showing
	
	var global_pos = dropdown_button.global_position
	var button_size = dropdown_button.size
	var popup_pos = global_pos + Vector2(0, button_size.y)
	
	# Use popup_on_parent instead of popup for better positioning
	popup.position = popup_pos
	popup.popup()

func _on_option_toggled(toggled: bool, opt: String) -> void:
	if toggled:
		if opt not in selected:
			selected.append(opt)
	else:
		selected.erase(opt)
	dropdown_button.text = ", ".join(selected) if selected.size() > 0 else "Select options"

func set_selected_by_texts(new_selected) -> void:
	selected = []
	for child in option_list.get_children():
		if child is CheckBox:
			var is_selected = child.text in new_selected
			child.set_pressed_no_signal(is_selected)
			if is_selected:
				selected.append(child.text)
	dropdown_button.text = ", ".join(selected) if selected.size() > 0 else "Select options"
