# Helper to generate the cats
class_name cat_generator

var colour_options := ["tortie", "tuxedo", "black", "ginger", "grey", "white", "tabby"]
var age_options := ["kitten", "adult"]
var breed_options := ["cat"]
var trait_options := ["friendly", "shy", "lazy", "greedy"]
var texture_options := {
	"cat-adult-black-friendly": load("res://assets/cat_textures/cat-black-friendly.png"),
	"cat-adult-black-lazy": load("res://assets/cat_textures/cat-black-lazy.png"),
	"cat-adult-black-shy": load("res://assets/cat_textures/cat-black-shy.png"),
	"cat-adult-black-greedy": load("res://assets/cat_textures/cat-black-greedy.png"),
	"cat-adult-ginger-friendly": load("res://assets/cat_textures/cat-ginger-friendly.png"),
	"cat-adult-ginger-lazy": load("res://assets/cat_textures/cat-ginger-lazy.png"),
	"cat-adult-ginger-shy": load("res://assets/cat_textures/cat-ginger-shy.png"),
	"cat-adult-ginger-greedy": load("res://assets/cat_textures/cat-ginger-greedy.png"),
	"cat-adult-grey-friendly": load("res://assets/cat_textures/cat-grey-friendly.png"),
	"cat-adult-grey-lazy": load("res://assets/cat_textures/cat-grey-lazy.png"),
	"cat-adult-grey-shy": load("res://assets/cat_textures/cat-grey-shy.png"),
	"cat-adult-grey-greedy": load("res://assets/cat_textures/cat-grey-greedy.png"),
	"cat-adult-tabby-friendly": load("res://assets/cat_textures/cat-tabby-friendly.png"),
	"cat-adult-tabby-lazy": load("res://assets/cat_textures/cat-tabby-lazy.png"),
	"cat-adult-tabby-shy": load("res://assets/cat_textures/cat-tabby-shy.png"),
	"cat-adult-tabby-greedy": load("res://assets/cat_textures/cat-tabby-greedy.png"),
	"cat-adult-tortie-friendly": load("res://assets/cat_textures/cat-tortie-friendly.png"),
	"cat-adult-tortie-greedy": load("res://assets/cat_textures/cat-tabby-greedy.png"),
	"cat-adult-tortie-shy": load("res://assets/cat_textures/cat-tortie-shy.png"),
	"cat-adult-tortie-lazy": load("res://assets/cat_textures/cat-tortie-lazy.png"),
	"cat-adult-tuxedo-friendly": load("res://assets/cat_textures/cat-tuxedo-friendly.png"),
	"cat-adult-tuxedo-greedy": load("res://assets/cat_textures/cat-tuxedo-greedy.png"),
	"cat-adult-tuxedo-laxy": load("res://assets/cat_textures/cat-tuxedo-lazy.png"),
	"cat-adult-tuxedo-shy": load("res://assets/cat_textures/cat-tuxedo-shy.png"),
	"cat-adult-white-friendly": load("res://assets/cat_textures/cat-white-friendly.png"),
	"cat-adult-white-greedy": load("res://assets/cat_textures/cat-white-greedy.png"),
	"cat-adult-white-lazy": load("res://assets/cat_textures/cat-white-lazy.png"),
	"cat-adult-white-shy": load("res://assets/cat_textures/cat-white-shy.png")
	}

var requests = [
	"I like breeds.",
	"I prefer breeds which are age.",
	"I am looking for a colour cat which is trait.",
	"I like trait cats.",
	"I would prefer a trait age cat.",
	"My favourite cats are colour.",
	"I don't mind so long as they are ages.",
	"I want a trait which is age and colour."
]

var adopter_textures = [
	load("res://assets/adopter_textures/adopter-one.png"),
	load("res://assets/adopter_textures/adopter-two.png"),
	load("res://assets/adopter_textures/adopter-three.png")
]

var adopter_number := 1
var cat_number := 1

func replace_elements(text:String, target: String, replacements: Array) -> Array:
	var request := text
	var replacement_list = []
	while request.find(target) != -1:
		var index := request.find(target)
		var replacement = replacements.pick_random()
		replacement_list.append(replacement)
		request = request.substr(0, index) + str(replacement) + request.substr(index + target.length())
	return [request, replacement_list]

func generate_request():
	var get_request = requests.pick_random()
	var wants = []
	if get_request.find("breed") != -1:
		var wanted_breed = breed_options.pick_random()
		get_request = get_request.replace("breed", wanted_breed)
		wants.append(wanted_breed)
	if get_request.find("age") != -1:
		var wanted_age = age_options.pick_random()
		get_request = get_request.replace("age", wanted_age)
		wants.append(wanted_age)
	if get_request.find("colour") != -1:
		var wanted_colour = colour_options.pick_random()
		get_request = get_request.replace("colour", wanted_colour)
		wants.append(wanted_colour)
	if get_request.find("trait") != -1:
		var returned_traits = replace_elements(get_request, "trait", trait_options)
		get_request = returned_traits[0]
		for t in returned_traits[1]:
			wants.append(t)
	return [get_request, wants]

func generate_adopter() -> adopter:
	var new_adopter = adopter.new()
	new_adopter.adopter_number = adopter_number
	new_adopter.texture = adopter_textures.pick_random()
	new_adopter.complete = false
	var request_and_traits = generate_request()
	new_adopter.request = request_and_traits[0]
	new_adopter.wants = request_and_traits[1]
	adopter_number += 1
	return new_adopter

func get_texture_by_cat_key(cat_key: String) -> Texture2D:
	if texture_options.has(cat_key):
		return texture_options[cat_key]
	return null 

func generate_cat() -> cat:
	var new_cat = cat.new()
	new_cat.cat_number = cat_number
	new_cat.name = "NoName"
	new_cat.colour = colour_options.pick_random()
	new_cat.age = age_options.pick_random()
	new_cat.breed = breed_options.pick_random()
	new_cat.traits = [trait_options.pick_random()]
	new_cat.adopted = false
	var cat_key = new_cat.breed + "-adult-" + new_cat.colour + "-" + new_cat.traits[0]
	new_cat.texture = get_texture_by_cat_key(cat_key)
	if new_cat.texture == null:
		return generate_cat()
	cat_number += 1
	return new_cat
