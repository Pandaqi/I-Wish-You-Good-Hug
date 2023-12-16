extends Node2D

var map
var map_size : Vector2
var map_center : Vector2

var num_players : int

var cell_size : float = 512 + 50
var cell_scene : PackedScene = preload("res://Scenes/Cell.tscn")

var score_cell : Node = null

onready var shift_tween : Tween = $ShiftTween
onready var player_manager = get_node("/root/Main/PlayerManager")
onready var effects_tween = get_node("/root/Main/EffectsTween")
onready var UI = get_node("/root/Main/UI")

var shift_tween_duration : float = 0.33
var cells_by_type = {}

var epsilon = 0.005
var solo_mode : bool = false

var unlocked_levels = []

func _ready():
	map_size = GlobalDict.cfg.map_size
	solo_mode = GlobalInput.get_player_count()

#
# HELPERS
#
func get_dimensions() -> Vector2:
	return map_size*cell_size

func convert_to_grid_pos(pos : Vector2) -> Vector2:
	return Vector2(floor(pos.x / cell_size), floor(pos.y / cell_size))

func out_of_bounds(pos : Vector2) -> bool:
	return pos.x < -epsilon or pos.x >= (map_size.x-epsilon) or pos.y < -epsilon or pos.y >= (map_size.y-epsilon)

func get_random_grid_pos() -> Vector2:
	return Vector2(randi() % int(map_size.x), randi() % int(map_size.y))

func get_random_grid_aligned_pos():
	return (get_random_grid_pos() + Vector2(0.5, 0.5)) * cell_size

#
# QUERIES
# (get pos with these requiements, get ...)
#
func get_random_pos(params = {}):
	var bad_pos = true
	var pos = Vector2.ZERO
	
	while bad_pos:
		bad_pos = false
		pos = get_random_grid_pos()
		
		var player_area = GlobalHelper.get_player_from_pos(pos)
		
		var cell = get_cell(pos)
		if params.has('default'):
			if not cell.is_default_type():
				bad_pos = true
				continue
		
		if params.has('empty'):
			if not cell.is_empty():
				bad_pos = true
				continue
		
		if params.has('player_area'):
			if not (player_area == params.player_area):
				bad_pos = true
				continue
		
		if params.has('forbid_player_area') and not solo_mode:
			if player_area == params.forbid_player_area:
				bad_pos = true
				continue
		
		# TO DO: This is HEAVY performance wise
		# Better to determine valid rows/cols at the start, and immediately disallow those?
		if params.has('in_line_with'):
			if not line_contains_type("row", pos, params.in_line_with) and not line_contains_type("col", pos, params.in_line_with):
				bad_pos = true
				continue
	
	return pos

func line_contains_type(dir, pos, types):
	var arr = get_all_cells_in_col(pos.x)
	if dir == "row": arr = get_all_cells_in_row(pos.y)
	
	for node in arr:
		if node.type in types:
			return true
	
	return false

func get_cell(pos):
	return map[pos.x][pos.y]

func set_cell(pos, node):
	map[pos.x][pos.y] = node

func will_move_out_of_bounds(node, dir):
	var pos = convert_to_grid_pos(node.get_global_position()) + dir 
	return out_of_bounds(pos)

func can_move_in_dir(node, dir):
	var pos = convert_to_grid_pos(node.get_global_position()) + dir 
	if out_of_bounds(pos): return false
	
	var cell = get_cell(pos)
	if cell.entry_forbidden(node): return false
	
	return true

func cell_can_teleport_in_dir(node, dir):
	var pos = convert_to_grid_pos(node.get_global_position()) + dir 
	if out_of_bounds(pos): return false
	
	var cell = get_cell(pos)
	if not cell.is_default_type(): return false
	
	return true

func get_my_cell(node):
	return get_cell(convert_to_grid_pos(node.get_global_position()))

func get_next_pos(node : Node, dir : Vector2, distance : float = 1.0) -> Vector2:
	return node.get_global_position() + dir*cell_size*distance

func get_most_unbalanced_player_area(wanted_type : String, forbidden_area : int = -1):
	var areas = get_player_areas_sorted(wanted_type)
	var skip_area = true
	
	var certainty_threshold = 3.25
	var skip_probability = 0.22
	
	if GlobalDict.cfg.bear_spawning.keep_to_same_area or GlobalInput.get_player_count() == 1:
		certainty_threshold = 0
	
	var counter = 0
	
	while skip_area:
		var ran_out_of_areas = (counter >= areas.size())
		if ran_out_of_areas: break
		
		var a = areas[counter]
		if a.full: continue
		
		# nothing here at all?! a certainty then!
		if a.score == 0 or a.num_of_type == 0: return areas[counter].num
		
		var diff = areas[areas.size() - 1].score - a.score
		var difference_small_enough_for_skip = (diff < certainty_threshold)
		if difference_small_enough_for_skip:
			if randf() <= skip_probability:
				counter += 1
				continue
		
		if forbidden_area > -1:
			if a.num == forbidden_area:
				counter += 1
				continue
		
		return a.num
	
	# no ideal candidate? just return one that is not full
	# (going from the LAST area to the FIRST, otherwise the last area in the list is NEVER triggered)
	for i in range(areas.size()-1, -1, -1):
		if not areas[i].full:
			return areas[i].num
	
	return null

func get_player_areas_sorted(wanted_type : String):
	var areas = []
	for i in range(num_players):
		areas.append({ 'num': i, 'num_items': 0, 'num_of_type': 0, 'full': true })
	
	for x in range(map_size.x):
		for y in range(map_size.y):
			var cell = get_cell(Vector2(x,y))
			var player_area = GlobalHelper.get_player_from_pos(Vector2(x,y))
			
			var a = areas[player_area]
			
			if cell.type == "bear":
				a.num_items += 1
				
				if cell.type == wanted_type:
					a.num_of_type += 1
			
			# an empty cell, with no content or players? this area is not full! yay!
			if (not cell.has_content()) and (not cell.has_players()) and cell.is_default_type():
				a.full = false
			
			if not cell.has_content(): continue

			a.num_items += 1
			
			if cell.content.type == wanted_type:
				a.num_of_type += 1
	
	for i in range(areas.size()):
		areas[i].score = areas[i].num_items + areas[i].num_of_type
		
		# with three players, one area is twice the size, so half the score
		if i == 1 and GlobalInput.get_player_count() == 3:
			areas[i].score *= 0.5
	
	areas.shuffle() # to keep ties from having the same order, always
	areas.sort_custom(self, "area_sort_comparator")
	
	return areas

func area_sort_comparator(a, b):
	return a.score < b.score

#
# MAP CREATING + POPULATING
#
func create_base_map() -> void:
	num_players = GlobalDict.cfg.num_players
	
	map = []
	map.resize(map_size.x)
	
	for x in range(map_size.x):
		map[x] = []
		map[x].resize(map_size.y)
		
		for y in range(map_size.y):
			var s = cell_scene.instance()
			var grid_pos = Vector2(x,y)
			var pos = (grid_pos + Vector2(0.5, 0.5)) * cell_size
			
			s.set_position(pos)
			s.initialize(grid_pos, self)
			
			add_child(s)
			
			s.set_type("")
			
			var rand_rot = randi() % 4
			if Global.in_campaign_mode(): rand_rot = 0
			s.perform_rotation(null, rand_rot)
			
			map[x][y] = s

func populate_map():
	create_dividers()
	place_special_cells()
	perform_modifications()

func create_dividers():
	var ignore_center = false
	
	# BETTER SOLO MODE; dividers change based on availability of cells that can move you around
	if num_players == 1: 
		var sf = GlobalDict.cfg.solo_split_field
		if sf == "none": 
			return
		elif sf == "partial":
			ignore_center = true
		elif sf == "full":
			pass
	
	# now add the wall of kitchen stuff in the center
	# (different walls are needed for different player counts)
	map_center = Vector2(floor(0.5*map_size.x), floor(0.5*map_size.y))
	for y in range(map_size.y):
		
		if y == map_center.y and ignore_center: continue
		
		var cell = map[map_center.x][y]
		cell.add_to_group("CenterSquares")
		cell.set_type("divider")
	
	var second_row_range = map_center.x
	if num_players == 4: second_row_range = map_size.x
	if num_players >= 3:
		for x in range(second_row_range):
			if x == map_center.x and ignore_center: continue
			
			var cell = map[x][map_center.y]
			cell.add_to_group("CenterSquares") 
			cell.set_type("divider")

func place_special_cells():
	var place_params = { 'default': true }
	
	# place the score cell
	score_cell = get_cell(get_random_pos(place_params))
	score_cell.set_type("score")
	
	var cells_to_place = GlobalDict.cfg.special_cells
	var cell
	
	var cur_player_area = randi() % num_players
	var solo_mode = (GlobalInput.get_player_count() == 1)
	
	for i in range(cells_to_place.size()):
		var tp = cells_to_place[i]
		var num_of_this_type = 0
		
		var temp_data = GlobalDict.cells[tp]
		if temp_data.has('num_per_player'):
			num_of_this_type = max( round(GlobalDict.cells[tp].num_per_player * num_players), 1)
		elif temp_data.has('fixed_num'):
			num_of_this_type = temp_data.fixed_num
		
			if solo_mode:
				num_of_this_type = max(floor(0.25*num_of_this_type), 2)
		
		for j in range(num_of_this_type):
			cur_player_area = (cur_player_area + 1) % num_players
			
			place_params.player_area = cur_player_area
			
			cell = get_cell(get_random_pos(place_params))
			cell.set_type(tp)

func perform_modifications():
	
	# MODIFICATION 1
	# replace some (but not all) trampolines with stores
	var stores_enabled = ("store" in GlobalDict.cfg.special_cells)
	if stores_enabled:
		var tramps = get_cells_by_type("trampoline")
		var num_to_replace = randi() % (tramps.size() - 1)
		
		tramps.shuffle()
		for i in range(num_to_replace):
			var tramp = tramps[i]
			tramp.set_type("store")

func create_campaign_map():
	create_campaign_terrain()
	create_level_selectors()
	hide_far_away_levels()

func create_campaign_terrain():
		
	# now set all cells to random terrain types to make it look better
	var grass_noise = OpenSimplexNoise.new()
	grass_noise.seed = randi()
	
	var water_noise = OpenSimplexNoise.new()
	water_noise.seed = randi()
	
	var forest_noise = OpenSimplexNoise.new()
	forest_noise.seed = randi()

	var types = ['decoration_grass', 'decoration_water', 'decoration_forest']
	var zoom_val = 0.1
	for x in range(map_size.x):
		for y in range(map_size.y):
			var cell = get_cell(Vector2(x,y))
			
			var temp_x = x / zoom_val
			var temp_y = y / zoom_val
			
			var noise_vals = [grass_noise.get_noise_2d(temp_x,temp_y), water_noise.get_noise_2d(temp_x,temp_y), forest_noise.get_noise_2d(temp_x,temp_y)]
			
			var highest_val = 0
			var corresponding_type = ""
			for i in range(noise_vals.size()):
				if noise_vals[i] <= highest_val: continue
				
				highest_val = noise_vals[i]
				corresponding_type = types[i]
			
			cell.set_type(corresponding_type)

func create_level_selectors():
	var num_levels = Global.load_campaign().size()
	
	var cols = 6
	var rows = ceil(num_levels / (cols+0.0))
	var offset_between_cells = Vector2(map_size.x / (cols+1.0), map_size.y / (rows+1.0))
	
	var save_data = Global.get_save_data().data
	var last_unlocked_level = Global.get_save_data().last_unlocked_level
	
	var disable_from_now_on : bool = false
	var last_enabled_cell : Vector2 = Vector2.ZERO
	
	unlocked_levels = []
	for i in range(1, num_levels):
		var x = i % cols
		var y = floor(i / (cols + 0.0))
		
		var pos = ((Vector2(x,y)+Vector2(0.5, 0.5))*offset_between_cells ).round()
		var cell = get_cell(pos)
		
		cell.set_type("campaign")
		cell.set_matching_level(i)
		
		if disable_from_now_on:
			cell.disable()
			continue
		
		last_enabled_cell = pos
		unlocked_levels.append(pos)
		
		if not Global.debugging:
			if i >= last_unlocked_level:
				disable_from_now_on = true
	
	# teleport players to locations around the last enabled cell
	var last_cell = get_cell(last_enabled_cell)
	var dirs = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	for i in range(4):
		var p = player_manager.players[i]
		
		var grid_pos = last_enabled_cell + dirs[i]
		if out_of_bounds(grid_pos):
			grid_pos = last_enabled_cell
		
		p.cur_cell.remove_player(p)
		get_cell(grid_pos).add_player(p)
		
		p.set_global_position((grid_pos+Vector2(0.5, 0.5)) * cell_size)

func hide_far_away_levels():
	var distance_threshold = 2
	
	for x in range(map_size.x):
		for y in range(map_size.y):
			var dist = INF
			for i in range(unlocked_levels.size()):
				var temp_dist = (unlocked_levels[i] - Vector2(x,y)).length()
				if temp_dist > dist: continue
				
				dist = temp_dist
			
			var cell = get_cell(Vector2(x,y))
			if dist > distance_threshold or cell.disabled:
				cell.set_type("divider")

func register_type(node, new_type, old_type):
	if cells_by_type.has(old_type):
		cells_by_type[old_type].erase(node)
	
	if not cells_by_type.has(new_type):
		cells_by_type[new_type] = []
	
	cells_by_type[new_type].append(node)

#
# SHIFTING
#
func get_cells_by_type(tp : String):
	if not cells_by_type.has(tp): return []
	return cells_by_type[tp] + []

func get_next_teleport_cell(cur_cell):
	var all_teleports = get_cells_by_type("teleport")
	var index = all_teleports.find(cur_cell)
	var next_index = (index + 1) % all_teleports.size()
	return all_teleports[next_index]

func get_all_cells_in_row(ind):
	var arr = []
	for i in range(map_size.x):
		arr.append(map[i][ind])
	
	return arr

func get_all_cells_in_col(ind):
	return map[ind]

func swap_cells(a,b):
	map[a.grid_pos.x][a.grid_pos.y] = b
	map[b.grid_pos.x][b.grid_pos.y] = a
	
	var temp = a.grid_pos
	a.grid_pos = b.grid_pos
	b.grid_pos = temp
	
	var temp2 = a.get_global_position()
	a.set_global_position(b.get_global_position())
	b.set_global_position(temp2)
	
	a.already_swapped = true
	b.already_swapped = true

func wrap_pos(pos):
	pos = Vector2(int(pos.x) % int(map_size.x), int(pos.y) % int(map_size.y))
	
	if pos.x < 0: pos.x += map_size.x
	if pos.y < 0: pos.y += map_size.y
	
	return pos

func get_wrap_field_offset(fly_dir):
	return -1 * map_size * cell_size * fly_dir

func shift(creator : Node, row : bool, ind : int, dir : int) -> void:
	# grab all cells we need to shift
	var cells = get_all_cells_in_col(ind)
	if row:
		cells = get_all_cells_in_row(ind)
	
	# SAFETY CHECK 1: if any of them is already being shifted, ignore it
	# SAFETY CHECK 2: don't allow shifting _other_ players (only if property enabled)
	for cell in cells:
		if cell.is_shifting(): return
		
		# TO DO: This is faulty, now that multiple players can be on a cell
		if GlobalDict.cfg.shifting.prevent_when_others_present:
			if cell.has_players() and not creator in cell.players: return
	
	# determine shift vector
	var shift_vec = Vector2.DOWN
	if row: shift_vec = Vector2.RIGHT
	
	# MODIFICATION 1: swap dividers with the cell behind them (if their "fixed" property is on)
	var keep_dividers_fixed = GlobalDict.cfg.shifting.keep_dividers_fixed
	for cell in cells:
		if keep_dividers_fixed:
			if cell.type == "divider" and not cell.already_swapped:
				var behind_pos = wrap_pos(cell.grid_pos - dir*shift_vec)
				
				var cell_behind = get_cell(behind_pos)
				swap_cells(cell, cell_behind)
	
	# play a tween to shift them
	# also mark them as "being shifted"
	for cell in cells:
		var old_pos = cell.get_position()
		var new_pos = old_pos + dir * shift_vec * cell_size

		# EXCEPTION 1: the outermost cell is teleported to the other side
		# (simply to make "level wrapping" work)
		if out_of_bounds(convert_to_grid_pos(new_pos)):
			var offset = -map_size.dot(shift_vec) * shift_vec * dir * cell_size

			cell.teleport_back(offset)
			old_pos += offset
			new_pos += offset
		
		cell.start_shift()
		
		# NOTE: content and player are a CHILD, so will automatically move with it and be updated internally when tween ends
		shift_tween.interpolate_property(cell, "position",
		old_pos, new_pos, shift_tween_duration,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	shift_tween.start()

func _on_ShiftTween_tween_completed(object, key):
	if key == ":position":
		object.end_shift()

#
# SPECIALTIES
#
func move_all_beds_in_dir(dir : Vector2) -> void:
	var beds = get_cells_by_type("bed") + []
	
	print("MOVING BEDS IN DIR")
	print(dir)
	
	for bed in beds:
		if not cell_can_teleport_in_dir(bed, dir): continue
		if bed.already_moved: continue
		
		var old_pos = bed.grid_pos
		var new_pos = bed.grid_pos + dir
		
		var old_rot = bed.sprite.get_rotation()
		
		var new_cell = get_cell(new_pos)
		var old_cell = get_cell(old_pos)
		
		new_cell.set_type("bed")
		old_cell.set_type("")
		
		new_cell.already_moved = true
		
		old_cell.override_rotation(old_cell.sprite.get_rotation())
		new_cell.override_rotation(old_rot)
	
	for bed in get_cells_by_type("bed"):
		bed.already_moved = false

func explode_in_radius(center_node : Node, radius : int = 1) -> void:
	var center_pos = center_node.grid_pos
	
	for x in range(-1,2):
		for y in range(-1,2):
			var pos = center_pos + Vector2(x,y)
			
			if out_of_bounds(pos): continue
			
			# TO DO: Only destroy bears? Randomly turn them into something else? What to do
			# TO DO: create "force_drop_object" function? To ensure these items are dropped?
			var cell = get_cell(pos)
			
			if cell.has_players():
				for p in cell.players:
					p.drop_object()
			
			if cell.has_content():
				cell.content.destroy()

func animate_the_whole_field():
	var removal_tween_duration = 0.3
	var max_removal_delay = 2 * removal_tween_duration
	
	# randomly scatter all cells away
	for x in range(map_size.x):
		for y in range(map_size.y):
			var cell = get_cell(Vector2(x,y))
			var rand_delay = randf() * max_removal_delay
			
			effects_tween.interpolate_property(cell, "scale",
			Vector2(1,1), Vector2.ZERO, removal_tween_duration,
			Tween.TRANS_ELASTIC, Tween.EASE_IN,
			rand_delay)
	
	# fade out players
	for node in get_tree().get_nodes_in_group("Players"):
		effects_tween.interpolate_property(node, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), (max_removal_delay + removal_tween_duration),
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	# fade out items
	for node in get_tree().get_nodes_in_group("Items"):
		effects_tween.interpolate_property(node, "modulate",
		Color(1,1,1,1), Color(1,1,1,0), removal_tween_duration,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	effects_tween.start()
	
	UI.set_visible(false)
