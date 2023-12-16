extends Node2D

var shifting : bool = false
var grid_pos : Vector2 = Vector2.ZERO
var map : Node2D = null

var type : String = ""
var data
var disabled : bool = false

var content : Node = null
var players = []

var already_swapped = false
var already_moved = false

onready var time_counter = $TimeCounter
onready var sprite = $Sprite
onready var spawner = get_node("/root/Main/Spawner")
onready var item_spawner = get_node("/root/Main/ItemSpawner")
onready var eff_tween = get_node("/root/Main/EffectsTween")
onready var effects_manager = get_node("/root/Main/EffectsManager")

var conveyor_belt_shader = preload("res://Shaders/ConveyorBelt.tres")

# only used on ONE CELL (score), can't I find a better system?
var score_gui_scene : PackedScene = preload("res://Scenes/ScoreGUI.tscn")
var score_gui : Node

# only use on ONE CELL (campaign), can't I find a better system? => turn these into their own scenes that are only instanced for this type?
var matching_level_index : int = -1

onready var label = $Label

# only used on ONE cell (big bear) again
var point_gui = null
var point_gui_scene = preload("res://Scenes/PointGUI.tscn")

func _ready():
	time_counter.create(self)

func initialize(grdp, mp):
	grid_pos = grdp
	map = mp

func _process(_dt):
	if not is_shifting(): return
	if not time_counter.is_visible(): return
	time_counter.update_to_cell_pos()

# mostly used on campaign cells for levels that aren't unlocked yet
func disable():
	disabled = true
	sprite.modulate.a = 0.5

func play_bounce_tween():
	var bounce_tween_duration = 0.33
	
	var old_scale = Vector2(1,1)
	var new_scale = Vector2(1.2, 1.2)
	
	var old_mod = Color(1,1,1,1)
	var new_mod = Color(1.2, 1.2, 1.2, 1.2)
	
	eff_tween.interpolate_property(self, "scale",
	old_scale, new_scale, 0.5*bounce_tween_duration,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	eff_tween.interpolate_property(self, "modulate",
	old_mod, new_mod, 0.5*bounce_tween_duration,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	eff_tween.interpolate_property(self, "scale",
	new_scale, old_scale, 0.5*bounce_tween_duration,
	Tween.TRANS_LINEAR, Tween.EASE_IN,
	0.5*bounce_tween_duration)
	eff_tween.interpolate_property(self, "modulate",
	new_mod, old_mod, 0.5*bounce_tween_duration,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	eff_tween.start()

#
# Point value
#
func update_points_value(dp : int):
	point_gui.update_gui(dp)

#
# Cell type
#
func set_type(tp : String) -> void:
	var old_type = type
	
	type = tp
	
	data = GlobalDict.cells[type]
	$Sprite.set_frame(data.frame)
	
	hide_time_counter()
	
	var enable_point_gui = GlobalDict.cfg.bear_spawning.use_point_gui
	var needs_time_counter = data.has('needs_time_counter')
	if type == "teleport" and GlobalDict.cfg.teleport_needs_timer:
		needs_time_counter = true
	
	if needs_time_counter:
		show_time_counter()
	
	if data.has('forbid_visual_rotation'):
		sprite.set_rotation(0)
	
	label.set_visible(false)
	if data.has('needs_label'):
		label.set_visible(true)
	
	if type == "score" or type == "campaign":
		var sg = score_gui_scene.instance()
		score_gui = sg
		add_child(sg)
	else:
		if score_gui:
			score_gui.queue_free()
	
	if old_type != type:
		if old_type == "bear" or old_type == "bed":
			spawner.removed_big_bear(self)
	
	# shifters get their type (row/column) determined when initialized
	if type == "shifter":
		var num_shifters = map.get_cells_by_type("shifter").size()
		var rot = (num_shifters % 2) * 0.5 * PI
		if GlobalDict.cfg.only_place_row_shifters: rot = 0
		
		sprite.set_rotation(rot)
	
	# teleporters must show their index
	if type == "teleport":
		var my_index = map.get_cells_by_type("teleport").size()
		label.set_text(str(my_index+1))
	
	# first, remove any point GUIs (almost all cells don't need it)
	if point_gui:
		point_gui.queue_free()
		point_gui = null
	
	# big bears get a point value GUI
	if type == "bear" and enable_point_gui:
		point_gui = point_gui_scene.instance()
		add_child(point_gui)
		
		point_gui.create(self)
		point_gui.update_gui(0)
		point_gui.set_global_position(get_global_position())
	
	# refresh shaders
	sprite.material = null
	
	if type == "conveyorbelt":
		sprite.material = conveyor_belt_shader
	
	map.register_type(self, type, old_type)
	
	play_bounce_tween()

#
# Time counter
#
func show_time_counter():
	time_counter.set_visible(true)
	time_counter.reset()

func hide_time_counter():
	time_counter.stop()
	time_counter.set_visible(false)

func has_active_time_counter():
	return time_counter.is_visible()

#
# PLAYERS
# 
func add_player(p):
	if has_player(p): return
	
	players.append(p)
	
	if p.get_parent(): p.get_parent().remove_child(p)
	add_child(p)
	
	p.set_cur_cell(self)

func remove_player(p):
	if not has_player(p): return
	
	remove_child(p)
	map.add_child(p)
	
	p.set_cur_cell(null)
	
	players.erase(p)

func has_player(p):
	return (p in players)

func has_players():
	return (players.size() > 0)

func has_disabled_player():
	for i in range(players.size()):
		if players[i].input_disabled: return true
	
	return false

func get_first_player():
	return players[0]

func teleport_back(dt):
	set_position(get_position() + dt)

func set_matching_level(i : int):
	matching_level_index = i
	
	score_gui.set_level_index(i)

#
# CONTENT
#
func has_content():
	return (content != null)

func add_content(node):
	if node.should_destroy: return
	
	content = node
	
	if node.get_parent(): node.get_parent().remove_child(node)
	add_child(node)
	
	var offset = Vector2.ZERO
	if data.has('content_offset'):
		offset = data.content_offset.rotated(node.sprite.get_rotation())
	
	node.set_position(offset)
	node.show_behind_parent = false
	
	node.respond_to_addition_to_cell(self)
	
	play_bounce_tween()

func remove_content():
	var temp = content
	
	remove_child(content)
	map.add_child(content)
	
	content = null
	
	play_bounce_tween()
	
	temp.respond_to_removal_from_cell()
	
	return temp

func has_content_with_correct_rotation(node):
	if not node.is_in_group("Players"): return true
	if not has_content(): return true
	if not content.data.has('rotation_matters'): return true
	
	return GlobalHelper.is_rotated_for_hug(node.sprite, content.sprite)

#
# SHIFTING
# 
func start_shift():
	shifting = true

func end_shift():
	shifting = false
	already_swapped = false
	
	grid_pos = map.convert_to_grid_pos(get_global_position())
	map.set_cell(grid_pos, self)
	
	if point_gui:
		point_gui.update_to_cell_pos()
	
	time_counter.update_to_cell_pos()

func is_shifting():
	return shifting


#
# ROTATING
#
func override_rotation(rot):
	sprite.set_rotation(rot)

func perform_rotation(creator : Node, amount : int):
	if not data.has('forbid_visual_rotation'):
		sprite.rotate(amount * 0.5 * PI)
	
	time_counter.update_gui()
	
	# if this rotation was setup/random, no special things need to happen
	if not creator:  return
	
	# rewinding can happen on timed cells
	# when you're rotating clockwise
	time_counter.handle_manual_rotation()
	
	if data.has("can_be_rewound"):
		if amount > 0:
			time_counter.rewind()
	
	# CRUCIAL CASE: the shifter responds to rotation
	if type == "shifter":
		var is_row_shifter = (sprite.get_rotation() == 0)
		var index_to_shift = grid_pos.x
		if is_row_shifter: index_to_shift = grid_pos.y
		
		map.shift(creator, is_row_shifter, index_to_shift, amount)
	
	# Gift wrapper creates either a GIFT or a HEART after a full rotation
	elif type == "giftwrapper":
		if (not has_players()) or has_content(): return
		 
		var p = get_first_player()
		
		# full circle CCW
		if p.num_rotations_on_this_cell <= -4:
			p.reset_cell_rotation_counter()
			item_spawner.place_item_of_type(p, self, "tinyheart")
		
		# full circle CW
		elif p.num_rotations_on_this_cell >= 4:
			p.reset_cell_rotation_counter()
			item_spawner.place_item_of_type(p, self, "tinygift")

func update_after_auto_rotation():
	if not has_players(): return
	
	for i in range(players.size()):
		players[i].pick_up_objects()

#
# HELPERS (availability, movability, etc.)
# 
func entry_forbidden(node):
	if is_shifting():
		return true
	
	if player_forbids_entry(node):
		effects_manager.create_feedback(node, "Blocked by player!")
		return true
	
	if rotation_incorrect(node):
		effects_manager.create_feedback(node, "Needs hug!")
		return true
	
	if settings_forbid_entry(node):
		return true
	
	if type == "campaign" and disabled:
		return true
	
	return false

func player_forbids_entry(node):
	if node.is_in_group("Items"): return false
	if GlobalDict.cfg.allow_cell_sharing_for_players: 
		
		if has_disabled_player(): return true
		else: return false
	
	return has_players()

func rotation_incorrect(node):
	if not data.has('rotation_matters'): return false
	if type != "bear" or not node.is_in_group("Players"): return false
	
	# This ONLY forbids player entry on big bears, 
	# tinybears are NEVER forbidden entry anywhere
	# EXCEPTION: if it's a bear, and our setting does NOT require a hug, then allow entry in all cases
	if type == "bear" and node.is_in_group("Players"):
		if GlobalDict.cfg.big_bear_requires_player_hug:
			return not GlobalHelper.is_rotated_for_hug(sprite, node.sprite)
		else:
			return false

func settings_forbid_entry(node):
	if type == "bed":
		if node.is_in_group("Players") and node.has_backpack():
			if not GlobalDict.cfg.players_can_stand_on_beds:
				effects_manager.create_feedback(node, "Can't enter bed with item")
				return true
	
	if data.has('disallow_entry_with_content'):
		if node.is_in_group("Players") and node.has_backpack():
			var is_exception = data.has("allowed_content") and (node.backpack.type in data.allowed_content)
			
			if not is_exception:
				effects_manager.create_feedback(node, "Can't enter with item!")
				return true
	
	if data.has('forbidden_objects'):
		if node.type in data.forbidden_objects:
			return true
	
	return false

func is_default_type():
	return (type == "")

func is_empty():
	return (not has_players() and not has_content())

#
# Timeout activation
# => whenever our time counter resets to 0, do something
#
func timeout_activation():
	match type:
		'trampoline':
			shoot_trampoline()
		
		'teleport':
			
			var did_something = false
			if has_content():
				content.perform_teleport()
				did_something = true
			
			if has_players():
				for p in players: p.perform_teleport()
				did_something = true
			
			if did_something: 
				GlobalAudio.play_sound(self, "woosh")
				if randf() <= 0.5: GlobalAudio.play_sound(self, "later")
			
			effects_manager.place_particles("rotate", self)
		
		'alarm':
			map.explode_in_radius(self, 1)
			
			GlobalAudio.play_sound(self, "alarm")
			
			for i in range(5):
				effects_manager.place_particles("rotate", self)
		
		'conveyorbelt':
			move_content_over_conveyor_belt()

func move_content_over_conveyor_belt():
	if not has_content(): return
	
	GlobalAudio.play_sound(self, "rumble")
	
	var rot = sprite.get_rotation()
	var dir = Vector2(cos(rot), sin(rot))
	
	if not map.can_move_in_dir(self, dir):
		if not content.wrapping_allowed({'override_steps': 1}): 
			return
	
	var cont = remove_content()
	
	cont.set_global_position(get_global_position())
	cont.start_flight(dir, 1)

func shoot_trampoline(params = {}):
	if not has_content(): return
	
	GlobalAudio.play_sound(self, "ploink")
	
	var cont = remove_content()
	var rot = sprite.get_rotation()
	if params.has('override_dir'):
		rot = params.override_dir
	
	var dir = Vector2(cos(rot), sin(rot))
	
	if not params.has('keep_item_rotation'):
		cont.sprite.set_rotation(rot)
	
	cont.set_global_position(get_global_position())
	cont.start_flight(dir)
