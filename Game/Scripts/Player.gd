extends Node2D

var player_num : int = -1
var data

onready var main_node = get_node("/root/Main")
onready var effects_manager = get_node("/root/Main/EffectsManager")
onready var eff_tween = get_node("/root/Main/EffectsTween")

var moving : bool = false
var rotating : bool = false
var disabled : bool = false

var vec : Vector2 = Vector2.ZERO
var deadzone = 0.5

var last_move_dir : Vector2 = Vector2.ZERO

var cur_cell : Node = null

onready var sprite = $Sprite

onready var step_counter = $StepCounter
var backpack : Node = null
var just_dropped_object = false
var num_steps : int = 0

var max_steps : int = 8 # => move to global config??
var max_steps_enabled : bool = false

onready var map : Node2D = get_node("/root/Main/Map")
onready var player_manager : Node2D = get_node("/root/Main/PlayerManager")
onready var tween : Tween = $Tween

onready var item_spawner : Node2D = get_node("/root/Main/ItemSpawner")
onready var score_manager : Node2D = get_node("/root/Main/ScoreManager")

var move_tween_duration : float = 0.33
var epsilon : float = 0.05

var ui_step_scene = preload("res://Scenes/UI-Step.tscn")

onready var ui_layer = get_node("/root/Main/UI") 

var type : String = "player"
var items_shoot_from_hands : bool = false
var rotation_disabled : bool = false

var touch_start : Vector2

var disabled_shader = preload("res://Shaders/PlayerDisabled.tres")
var input_disabled : bool = false

onready var move_particles = $Sprite/MoveParticles
onready var rotate_particles = $Sprite/RotateParticles

onready var teleport_timer = $TeleportTimer
var just_teleported = false

var num_rotations_on_this_cell : int = 0

onready var feedback_timer = $FeedbackTimer
var feedback_disabled : bool = false

func _ready():
	create_backpack_gui()
	data = GlobalDict.items.player

	items_shoot_from_hands = GlobalDict.cfg.moving.items_shoot_from_hands
	
	rotation_disabled = GlobalDict.cfg.disable_rotation_input
	
	# NOTE: keep rotate particles on, I like the effect upon level load
	move_particles.set_emitting(false)
	
	if not GlobalHelper.is_mobile():
		$Area2D.queue_free()

func set_player_num(i : int):
	player_num = i
	sprite.set_frame(i)

func disable():
	sprite.material = disabled_shader
	input_disabled = true

func enable():
	sprite.material = null
	input_disabled = false

func _process(_dt):
	update_backpack_position()
	poll_joystick_input()
	check_movement()
	check_rotation()

func update_backpack_position():
	if not backpack: return
	
	step_counter.set_global_position(get_global_position())

func poll_joystick_input():
	if GlobalHelper.is_mobile(): return
	if input_disabled: return
	
	var h = Input.get_action_strength(get_key("right")) - Input.get_action_strength(get_key("left"))
	var v = Input.get_action_strength(get_key("down")) - Input.get_action_strength(get_key("up"))
	
	vec = Vector2(h,v)

func _input(ev):
	if input_disabled: return
	
	var rotate_key = get_key("rotate")
	if ev.is_action_pressed(rotate_key):
		start_rotating()
	elif ev.is_action_released(rotate_key):
		stop_rotating()

#
# CELL MANAGEMENT
#
func set_cur_cell(node):
	cur_cell = node

#
# HELPERS
#
func get_key(key : String):
	var device_num = GlobalInput.device_order[player_num]
	return key + "_" + str(device_num)

func convert_to_grid_aligned_vec(temp_vec : Vector2) -> Vector2:
	var diagonal_threshold = 0.4
	
	var new_vec = Vector2.ZERO
	if abs(temp_vec.x) > diagonal_threshold: new_vec.x = sign(temp_vec.x)
	if abs(temp_vec.y) > diagonal_threshold: new_vec.y = sign(temp_vec.y)
	return new_vec

func snap_vec_to_grid(temp_vec : Vector2) -> Vector2:
	var angle = atan2(temp_vec.y, temp_vec.x)
	if abs(angle) <= 0.25*PI:
		return Vector2.RIGHT
	elif abs(angle - 0.5*PI) <= 0.25*PI:
		return Vector2.DOWN
	elif abs(angle + 0.5*PI) <= 0.25*PI:
		return Vector2.UP
	else:
		return Vector2.LEFT

func get_angle_from_vec(temp_vec : Vector2) -> float:
	temp_vec = temp_vec.normalized()
	return atan2(temp_vec.y, temp_vec.x)

# on mobile, stuff happens when finger is released, so reset vector afterwards
func reset_vec_on_mobile():
	if not GlobalHelper.is_mobile(): return
	vec = Vector2.ZERO

#
# MOVING
#
func check_movement():
	if moving or rotating or disabled: return
	if input_disabled: return
	if vec.length() < deadzone: return

	var move_vec = convert_to_grid_aligned_vec(vec)
	
	if has_backpack() and GlobalDict.cfg.moving.forbid_diagonal_if_backpack:
		move_vec = snap_vec_to_grid(vec)
	
	reset_vec_on_mobile()

	if not map.can_move_in_dir(self, move_vec): 
		return

	perform_move(move_vec)

func perform_teleport():
	if just_teleported: return
	
	input_disabled = true
	moving = true
	
	teleport_timer.stop()
	teleport_timer.start()

func _on_TeleportTimer_timeout():
	var new_cell = map.get_next_teleport_cell(cur_cell)
	
	if new_cell.has_players(): 
		effects_manager.create_feedback(self, "Target is occupied!")
		return
	
	cur_cell.remove_player(self)
	new_cell.add_player(self)
	
	set_global_position(new_cell.get_global_position())
	
	input_disabled = false
	moving = false
	
	just_teleported = true

func perform_move(dir : Vector2):
	moving = true
	
	last_move_dir = dir
	just_teleported = false
	just_dropped_object = false
	
	reset_cell_rotation_counter()
	
	# calculate destinations
	var old_pos = get_global_position()
	var new_pos = map.get_next_pos(self, dir)
	
	# Remove from old cell, add to new
	# NOTE: we do it here, so other players could potentially enter immediately after us
	cur_cell.remove_player(self)
	
	var new_cell = map.get_cell(map.convert_to_grid_pos(new_pos))
	new_cell.add_player(self)
	
	# start move tween
	var offset = new_pos - old_pos
	
	self.set_position(Vector2.ZERO-offset)
	
	move_particles.set_emitting(true)
	
	tween.interpolate_property(self, "position",
	Vector2.ZERO-offset, Vector2.ZERO, move_tween_duration,
	Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.start()
	
	GlobalAudio.play_sound(self, "move", -3)

func finish_move():
	move_particles.set_emitting(false)
	
	# check if our current cell (automatically!) does something special
	evaluate_current_cell()
	
	# NOTE: must come before picking up, otherwise we also count that as a step
	update_steps_after_move() 
	check_for_item_auto_drop()
	pick_up_objects()
	
	moving = false

func evaluate_current_cell():
	
	var droppable = false
	if cur_cell.data.has('auto_drop'): droppable = true
	if has_backpack() and backpack.data.has('needs_max_steps'): droppable = false
	
	var dot_prod = 0
	var rot_vec = Vector2(cos(sprite.get_rotation()), sin(sprite.get_rotation())).round()
	var rot_as_int = GlobalHelper.convert_rotation_to_int(sprite.get_rotation())
	
	if cur_cell.data.has('four_directional_cell'):
		dot_prod = rot_vec.dot(Vector2.RIGHT)
	
	match cur_cell.type:
		'rotator':
			perform_rotation(1)
		
		'shooter':
			if droppable: 
				drop_object()
		
		'trampoline':
			if droppable: drop_object()
		
		'stepchanger':
			if not max_steps_enabled: return
			var increase = abs(dot_prod) >= 0.95
			
			var update_val = 1 if increase else -1
			update_step_counter(update_val)
			
			GlobalAudio.play_sound(self, "ploink")
		
		'bedmover':
			map.move_all_beds_in_dir(rot_vec)
			
			var sound = "rumble"
			if randf() <= 0.5: sound = "woosh"
			
			GlobalAudio.play_sound(self, sound)
		
		'teleport':
			if cur_cell.has_active_time_counter():
				if droppable: drop_object()
				return
			
			self.perform_teleport()
			
			var sound = "later"
			if randf() <= 0.5: sound = "woosh"
			
			GlobalAudio.play_sound(self, sound)
		
		'autoshifter':
			var row = (abs(rot_vec.x) > 0.005)
			var ind = cur_cell.grid_pos.x
			if row: ind = cur_cell.grid_pos.y
			
			var dir = 1
			if row: dir = sign(rot_vec.x)
			else: dir = sign(rot_vec.y)
			
			map.shift(self, row, ind, dir)
			
			var sound = "rumble"
			if randf() <= 0.5: sound = "woosh"
			
			GlobalAudio.play_sound(self, sound)
		
		'store':
			if rot_as_int == 0:
				item_spawner.place_item_of_type(self, cur_cell, "tinycactus")
			elif rot_as_int == 1:
				item_spawner.place_item_of_type(self, cur_cell, "tinypillow")
			
			elif rot_as_int == 2:
				score_manager.update_points(self, -2)
			else:
				cur_cell.set_type("trampoline")
			
			# TO DO: Sound of clanking coins?

		# campaign level cells can have multiple players, and will start the level when ALL players stand on it
		'campaign':
			main_node.update_level_info(cur_cell.matching_level_index)
			
			var num_players = GlobalInput.get_player_count()
			if cur_cell.players.size() < num_players or num_players <= 1: return
			
			print(num_players)

			Global.load_level(cur_cell.matching_level_index)
			get_tree().reload_current_scene()

func _on_Tween_tween_completed(_object, key):
	if key == ":position":
		finish_move()
	
	elif key == ":rotation":
		finish_rotation()

#
# Backpack GUI
#
func create_backpack_gui():

	for i in range(max_steps):
		var s = ui_step_scene.instance()
		step_counter.add_child(s)
		
		var angle = 1.5*PI - i*0.25*PI
		var offset_vec = Vector2(cos(angle), sin(angle))
		
		s.set_position(offset_vec * 0.5 * 512)
		s.set_rotation(angle)
		
		s.name = "UIStep" + str(i)
	
	remove_child(step_counter)
	ui_layer.add_child(step_counter)
	
	step_counter.set_visible(false)

func update_backpack_gui():
	for i in range(max_steps):
		var node = step_counter.get_node("UIStep" + str(i))
		
		node.set_visible((i < num_steps))

func start_backpack_gui():
	num_steps = backpack.get_num_steps()
	
	if not max_steps_enabled: 
		num_steps = 0
		step_counter.get_node("BackpackIcon").set_visible(true)
	else:
		step_counter.get_node("BackpackIcon").set_visible(false)
	
	step_counter.set_visible(true)
	update_backpack_gui()

func end_backpack_gui():
	step_counter.set_visible(false)

#
# Backpack
#
func check_for_item_auto_drop():
	if not has_backpack(): return
	if max_steps_enabled: return
	
	var should_drop = backpack.can_drop_here(cur_cell)
	
	if not should_drop: return
	drop_object()

func has_backpack():
	return (backpack != null)
	
func update_steps_after_move():
	if not backpack: return
	if not max_steps_enabled: return

	var ds = -1
	if GlobalHelper.is_diagonal(last_move_dir): ds = -2
	
	update_step_counter(ds)

func update_steps_after_rotation():
	if not has_backpack(): return false
	if not max_steps_enabled: return false
	if not GlobalDict.cfg.moving.rotation_counts_as_step: return false
	
	return update_step_counter(-1)

func update_step_counter(ds : int):
	num_steps += ds
	update_backpack_gui()
	
	if num_steps <= 0: drop_object()

func snatch_flying_object(node):
	if has_backpack(): return
	if node.data.has('rotation_matters'):
		if not GlobalHelper.is_rotated_for_hug(node.sprite, sprite): 
			return

	add_to_backpack(node)

func pick_up_objects():
	if not cur_cell.has_content(): return false # nothing to pick up?
	if has_backpack(): return false # backpack already full?
	if just_dropped_object: return false
	if cur_cell.content.should_destroy: return false
	
	# for some reason, we cannot pick up this specific thing?
	if not cur_cell.has_content_with_correct_rotation(self): 
		effects_manager.create_feedback(self, "Needs hug!")
		return false
	
	add_to_backpack( cur_cell.remove_content() )
	return true

func add_to_backpack(node):
	backpack = node
	
	if node.get_parent(): node.get_parent().remove_child(node)
	add_child(node)
	
	max_steps_enabled = node.data.has('needs_max_steps') and GlobalDict.cfg.moving.use_max_steps
	
	start_backpack_gui()
	node.respond_to_addition_to_backpack(self)
	
	if node.type == "tinycactus":
		GlobalAudio.play_sound(self, "auw")
	elif node.type == "tinygift":
		GlobalAudio.play_sound(self, "thanks")
	else:
		GlobalAudio.play_sound(self, "hmm")
	
	play_squeeze_tween()

func play_squeeze_tween():
	var old_scale = Vector2(1,1)
	var new_scale = Vector2(0.7, 0.7)
	
	var squeeze_tween_duration = 0.3
	
	eff_tween.interpolate_property(self, "scale", 
	old_scale, new_scale, 0.5*squeeze_tween_duration,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	eff_tween.interpolate_property(self, "scale", 
	new_scale, old_scale, 0.5*squeeze_tween_duration,
	Tween.TRANS_LINEAR, Tween.EASE_IN,
	0.5*squeeze_tween_duration)
	
	eff_tween.start()

func drop_object():
	if cur_cell.has_content(): return # can't drop this here?
	if not backpack: return # nothing in backpack?
	
	cur_cell.add_content( empty_backpack() )
	
	if items_shoot_from_hands or cur_cell.type == "shooter":
		cur_cell.shoot_trampoline({ 'override_dir': sprite.get_rotation() })
	
	just_dropped_object = true

func empty_backpack():
	var temp = backpack
	
	backpack.respond_to_removal_from_backpack()

	backpack = null
	end_backpack_gui()
	return temp

#
# ROTATING
#
func start_rotating():
	if rotation_disabled: return
	
	rotating = true
	$Timer.stop()

func stop_rotating():
	if rotation_disabled: return
	
	rotating = false
	disabled = true
	$Timer.start()
	
	reset_vec_on_mobile()

func make_angle_positive(ang : float) -> float:
	while ang < 0: ang += 2*PI
	return ang

func get_angle_as_int(ang : float) -> int:
	return int( round(ang / (0.5*PI)) )

func convert_angle_to_vec(ang : float) -> Vector2:
	return Vector2(cos(ang), sin(ang))

func check_rotation():
	if not rotating: return
	if vec.length() <= epsilon: return
	
	var snapped_vec = snap_vec_to_grid(vec)
	
	var a = convert_angle_to_vec(sprite.get_rotation()).round()
	var b = snapped_vec
	
	var dot_prod = a.x*-b.y + a.y*b.x
	
	# b on the right of a
	if dot_prod > 0:
		perform_rotation(-1)
	
	# b on the left of a
	elif dot_prod < 0:
		perform_rotation(1)
	
	# parallel or anti-parallel
	else:
		# parallel! do nothing
		if (a - b).length() <= epsilon:
			return
		
		# anti-parallel! we just always go clockwise then, quarter steps until we get there
		else:
			perform_rotation(1)

func reset_cell_rotation_counter():
	num_rotations_on_this_cell = 0

func update_cell_rotation_counter(dr):
	num_rotations_on_this_cell += dr

func perform_rotation(amount : int):
	update_cell_rotation_counter(amount)
	
	if GlobalDict.cfg.cells_rotate_with_player:
		cur_cell.perform_rotation(self, amount)
	
	just_dropped_object = false
	
	var rot_angle = amount * 0.5 * PI
	sprite.rotate(rot_angle)
	
	check_for_item_auto_drop()
	update_steps_after_rotation()
	
	rotate_particles.restart()
	rotate_particles.set_emitting(true)
	
	if has_backpack(): 
		backpack.perform_rotation(self, amount)
	
	GlobalAudio.play_sound(self, "rotate", -5)
	
	# check if we can pick something up NOW, that we're rotated
	pick_up_objects() 

func finish_rotation():
	rotate_particles.set_emitting(false)

# Timer ensures we don't immediately move after rotating, as that is annoying
func _on_Timer_timeout():
	disabled = false

#
# TOUCH INPUT
#
func handle_touch_event(world_pos, ev):
	if input_disabled: return
	
	if ev.pressed: 
		touch_start = world_pos
	else: 
		vec = (world_pos - touch_start).normalized()

func handle_drag_event(world_pos, ev):
	if input_disabled: return
	if not rotating: return

	vec = (world_pos - get_global_position()).normalized()

# called from our Area2D after a touch
func press(ev):
	if not Global.in_campaign_mode(): return
	
	# either we're too early with clicking this one, or it was already clicked
	if GlobalInput.get_player_count() != player_num: return
	
	# only check release, not press
	if ev.pressed: return
	
	GlobalInput.add_new_player('keyboard')
	enable()

func _on_FeedbackTimer_timeout():
	feedback_disabled = false

func disable_feedback():
	feedback_disabled = true
	
	feedback_timer.stop()
	feedback_timer.start()
