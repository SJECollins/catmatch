extends Node

signal create_sprites
signal switch_to_kennel
signal adoption_complete

var scene_reception: Node = null
var scene_kennels: Node = null
var current_scene: Node = null

var adoptions: int = 0
var score: float = 0.0

@export var cat_array: Array = []
@export var adopter_array: Array = []

@export var adopted_cats: Array = []
@export var completed_adopters: Array = []

@export var user_cat_data_array: Array = []

@onready var helper_functions = load("res://scripts/helpers/cat_request_generator.gd").new()
@onready var btn_switch_scene = $"../BtnSwitchScene"

var selected_adopter = null
var selected_cat = null

var overall_wants = 0
var overall_met_wants = 0

func _match_cat(the_cat: cat, the_adopter: adopter):
	var total_wants = the_adopter["wants"].size()
	overall_wants += total_wants
	var met_wants = 0
	for want in the_adopter["wants"]:
		if the_cat["colour"].to_lower() == want.to_lower():
			met_wants += 1
		if the_cat["age"].to_lower() == want.to_lower():
			met_wants += 1
		if the_cat["breed"].to_lower() == want.to_lower():
			met_wants += 1
		for a_trait in the_cat["traits"]:
			if a_trait.to_lower() == want:
				met_wants += 1
	overall_met_wants += met_wants
	return [total_wants, met_wants]

func adopt_cat():
	selected_adopter = scene_reception.active_adopter
	
	if selected_adopter == null or selected_cat == null:
		scene_reception.get_node("DialogBox")._display_text("Select cat and adopter")
		return
		
	# Find the cat and adopter objects
	var the_cat = null
	var cat_index = -1
	for i in cat_array.size():
		if cat_array[i].cat_number == selected_cat:
			the_cat = cat_array[i]
			cat_index = i
			break
	
	var the_adopter = null
	var adopter_index = -1
	for i in adopter_array.size():
		if adopter_array[i].adopter_number == selected_adopter:
			the_adopter = adopter_array[i]
			adopter_index = i
			break
	# Check if we found both
	if the_cat == null or the_adopter == null:
		scene_reception.get_node("DialogBox")._display_text("Could not find cat or adopter")
		return
	
	var want_results = _match_cat(the_cat, the_adopter)
	# Mark as adopted and complete
	the_cat["adopted"] = true
	the_adopter["complete"] = true
	
	# Remove cat from cat_array and add to adopted_cats
	var adopted_cat = cat_array.pop_at(cat_index)
	adopted_cats.append(adopted_cat)
	
	# Remove from user_cat_data_array
	for i in range(user_cat_data_array.size() - 1, -1, -1):
		if user_cat_data_array[i].cat_number == the_cat.cat_number:
			user_cat_data_array.remove_at(i)
			break
	var completed_adopter = adopter_array.pop_at(adopter_index)
	completed_adopters.append(completed_adopter)
	
	scene_reception.active_adopter = null
	scene_reception.get_node("DialogBox")._display_text("Thank you.\nThis cat matches " + str(want_results[1]) + " out of " + str(want_results[0]))
	scene_reception.get_node("StatDisplay")._update_stats(str(adopted_cats.size()), str(overall_met_wants), str(overall_wants))

	scene_reception._next_adopter(selected_adopter)
	scene_kennels._clear_cat_sprite(selected_cat)
	selected_adopter = null
	selected_cat = null

func _on_start_game():
	scene_reception._create_adopters(3)
	scene_kennels._create_cats(5)

func switch_to_scene():
	if current_scene != null:
		current_scene.visible = false
	var new_scene = null
	if current_scene == scene_reception:
		new_scene = scene_kennels
		btn_switch_scene.text = "Go To\nReception"
	else:
		new_scene = scene_reception
		btn_switch_scene.text = "Go To\nKennels"
		emit_signal("switch_to_kennel")
	new_scene.visible = true
	current_scene = new_scene
	btn_switch_scene.release_focus()

func _ready() -> void:
	scene_reception = preload("res://scene/game/reception.tscn").instantiate()
	scene_kennels = preload("res://scene/game/kennels.tscn").instantiate()
	$"../SceneContainer".add_child(scene_reception)
	$"../SceneContainer".add_child(scene_kennels)
	scene_kennels.visible = false
	current_scene = scene_reception
	btn_switch_scene.text = "Go To\nKennels"
	btn_switch_scene.pressed.connect(switch_to_scene)
	scene_reception.get_node("Foreground/Computer").connect("try_adoption", adopt_cat)
