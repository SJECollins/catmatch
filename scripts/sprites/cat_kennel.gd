extends Node2D

var cat_data
@onready var sprite: Sprite2D = $CatSprite
@onready var anim_player: AnimationPlayer = $CatSprite/CatAnimation
@onready var kennels = get_node("/root/Game/SceneContainer/Kennels")

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		kennels.cat_selected(cat_data.cat_number)

func get_frame(spritesheet: Texture2D, frame_size: Vector2i, index: int) -> AtlasTexture:
	var region = Rect2i(Vector2i(index * frame_size.x, 0), frame_size)
	var atlas = AtlasTexture.new()
	atlas.atlas = spritesheet
	atlas.region = region
	return atlas

func setup_custom_animation(spritesheet: Texture2D, frame_size: Vector2i, frame_order: Array[int], frame_durations: Array[float]) -> void:
	var animation = Animation.new()
	animation.loop_mode = Animation.LOOP_LINEAR  # Updated property name
	animation.add_track(Animation.TYPE_VALUE)
	
	# Path relative from AnimationPlayer to the Sprite2D node's texture property
	animation.track_set_path(0, ".:texture")
	
	var time = 0.0
	for i in range(frame_order.size()):
		var frame_index = frame_order[i]
		var tex = get_frame(spritesheet, frame_size, frame_index)
		animation.track_insert_key(0, time, tex)
		time += frame_durations[i]
	
	# Set the animation length to the total time
	animation.length = time
	
	# Create an AnimationLibrary and add the animation to it
	var animation_library = AnimationLibrary.new()
	animation_library.add_animation("custom", animation)
	
	# Add the library to the AnimationPlayer (use "" for default library)
	anim_player.add_animation_library("", animation_library)
	
	# Wait a frame to ensure the animation is properly registered
	await get_tree().process_frame
	
	# Play the animation
	anim_player.play("custom")

func _rand_short():
	return randf_range(1, 2)

func _rand_long():
	return randf_range(3, 5)

func _rand_position():
	if cat_data.traits.has("greedy"):
		return Vector2(80, 26)
	var rand_pos = [1, 2, 3].pick_random()
	if rand_pos == 1:
		return Vector2(92, 86)
	elif rand_pos == 2:
		return Vector2(92, 28)
	else:
		return Vector2(26, 84)

func _ready() -> void:
	sprite.position = _rand_position()
	var short = _rand_short()
	var long = _rand_long()
	if cat_data.age == "kitten":
		sprite.position.y += 8
		sprite.scale = Vector2(0.75, 0.75)
	if cat_data.traits.has("friendly"):
		await setup_custom_animation(cat_data.texture, Vector2i(64, 64), [0, 1, 0, 2, 3, 4], [long, short, long, short, short, short])
	elif cat_data.traits.has("lazy"):
		await setup_custom_animation(cat_data.texture, Vector2i(64, 64), [0, 1, 2, 3, 2, 1], [long, short, short, long, short, short])
	elif cat_data.traits.has("shy"):
		await setup_custom_animation(cat_data.texture, Vector2i(64, 64), [0, 1], [long, short])
	elif cat_data.traits.has("greedy"):
		await setup_custom_animation(cat_data.texture, Vector2i(64, 64), [0, 1, 2, 3, 4], [long, short, short, long, short])
