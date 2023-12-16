extends Node2D

var num_steps : int
var data
var type : String

# TO DO: In future projects, put these properties in a dictionary
# Or, make it a "module" that handles itself
var fly_dir : Vector2
var fly_tween_duration : float = 0.33 # TO DO => make global

var flying : bool = false
var cur_cell : Node = null
var fly_target_pos : Vector2
var fly_max_steps : int

var in_backpack : bool = false
var cur_backpack_owner : Node = null

var in_cell : bool = false

var should_destroy : bool = false

onready var map = get_node("/root/Main/Map")
onready var tween = $Tween
onready var spawner = get_node("/root/Main/Spawner")
onready var item_spawner = get_node("/root/Main/ItemSpawner")
onready var score_manager = get_node("/root/Main/ScoreManager")
onready var effects_manager = get_node("/root/Main/EffectsManager")

onready var sprite = $Sprite
onready var timer = $Timer

onready var fly_particles = $Sprite/FlyParticles
onready var anim_player = $AnimationPlayer

onready var teleport_timer = $TeleportTimer

var players_that_held_me = []

func _ready():
	fly_particles.set_emitting(false)
	if not GlobalDict.cfg.auto_rotate_bears: timer.queue_free()

func set_type(tp : String) -> void:
	var old_type = tp
	
	type = tp
	
	data = GlobalDict.items[type]
	$Sprite.set_frame(data.frame)
	
	if old_type != type:
		if old_type == "tinybear":
			spawner.bear_removed()

func get_num_steps() -> int:
	return data.num_steps

func start_flight(dir : Vector2, max_steps : int = -1) -> void:
	fly_dir = dir
	z_index = 2000
	flying = true
	fly_max_steps = max_steps
	
	fly_particles.set_emitting(true)
	anim_player.play("FlyParticleSwerve")
	
	effects_manager.place_particles("arrow", self, { 'rotation': sprite.get_rotation() + PI })
	
	if type == "tinybear":
		var sound = "fly"
		if randf() <= 0.5: sound = "wiehoo"
		
		GlobalAudio.play_sound(self, sound)
	
	fly_further()

func finish_flight():
	# clearly, if we're in a backpack, we already stopped flying
	if in_backpack: return
	
	var cell = map.get_my_cell(self)
	flying = false
	
	fly_particles.set_emitting(false)
	anim_player.stop()
	
	cell.add_content(self)

func respond_to_addition_to_backpack(backpack_owner):
	cur_backpack_owner = backpack_owner
	
	set_position(Vector2.ZERO)
	z_index = 500
	show_behind_parent = true
	in_backpack = true
	
	if flying:
		fly_particles.set_emitting(false)
		anim_player.stop()
		flying = false
	
	if data.points.has('player_backpack'):
		score_manager.update_points(self, data.points.player_backpack)
	
	# EXCEPTION: The gift removes itself (and gives points) once all players have held it (at least once)
	if not (backpack_owner in players_that_held_me):
		players_that_held_me.append(backpack_owner)
		
		if type == "tinygift" and (players_that_held_me.size() >= GlobalDict.cfg.num_players):
			backpack_owner.drop_object()
			backpack_owner.cur_cell.content.destroy(true)
			
			score_manager.update_points(self, data.points.all_players_touched)

func respond_to_removal_from_backpack():
	in_backpack = false

func respond_to_removal_from_cell():
	in_cell = false

func respond_to_addition_to_cell(cell):
	cur_cell = cell
	in_cell = true
	
	z_index = 500
	
	# HOLE: just destroy ourselves
	if cell.type == "hole":
		destroy()
		return
	
	# CRUCIAL CASE: tiny bear is delivered
	# (Either it hugs a big bear, or is in bed with correct rotation
	if type == "tinybear":
		var delivered = false
		if cur_cell.type == "bear" or cur_cell.type == "bed": 
			delivered = true
		
		# TO DO: do this removal slowly, animated
		if delivered:
			GlobalAudio.play_sound(self, "hmm")
			
			if randf() <= 0.1:
				GlobalAudio.play_sound(self, "snore", -6)
			
			destroy(true)
			cur_cell.set_type("")
	
	# Hearts increase point value of big bears
	elif type == "tinyheart":
		if cur_cell.type == "bear":
			GlobalAudio.play_sound(self, "hmm")
			destroy(true)
			cur_cell.update_points_value(data.points.cell_addition)

func destroy(good = false):
	should_destroy = true
	
	if not is_instance_valid(self): return
	
	var points = data.points.removal
	if good: points = data.points.delivery

	score_manager.update_points(cur_cell, points)
	
	if in_cell and cur_cell:
		cur_cell.remove_content()
		set_global_position(cur_cell.get_global_position())
	
	anim_player.play("FadeOut")

	if type == "tinybear": 
		spawner.removed_bear()
		var sound = "hmm" if randf() <= 0.5 else "wiehoo"
		if not good: sound = "noo"
		GlobalAudio.play_sound(self, sound)
	else: 
		item_spawner.removed_item()

func destroy_on_anim_complete():
	self.queue_free()

func fly_further():
	var old_pos = get_global_position()
	var inter_pos_1 = map.get_next_pos(self, fly_dir, 0.5)
	var inter_pos_2 = inter_pos_1
	
	var offset = map.get_wrap_field_offset(fly_dir)
	var wrapping = false
	
	# if we can wrap the field, just teleport to the other side on the half tween
	# otherwise, schedule ourselves for removal
	if map.will_move_out_of_bounds(self, fly_dir):
		if wrapping_allowed():
			inter_pos_2 += offset
			wrapping = true
		else:
			should_destroy = true
	
	if not should_destroy and not wrapping:
		if not map.can_move_in_dir(self, fly_dir):
			finish_flight()
			return
	
	var new_pos = map.get_next_pos(self, fly_dir)
	if wrapping: new_pos += offset

	tween.interpolate_property(self, "position",
	old_pos, inter_pos_1, 0.5*fly_tween_duration,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	tween.interpolate_property(self, "position",
	inter_pos_2, new_pos, 0.5*fly_tween_duration,
	Tween.TRANS_LINEAR, Tween.EASE_OUT,
	0.5*fly_tween_duration)
	
	fly_target_pos = new_pos
	
	tween.start()

func wrapping_allowed(params = {}):
	var temp_max_steps = fly_max_steps
	if params.has('override_steps'): temp_max_steps = params.override_steps
	
	var has_max_flight_dist = (temp_max_steps > 0)
	var wrapping_allowed = GlobalDict.cfg.moving.bears_wrap_field or not data.has('destroy_on_wrap') or has_max_flight_dist
	
	return wrapping_allowed

func _on_Tween_tween_completed(_object, key):
	if not key == ":position": return
	if get_global_position() != fly_target_pos: return
	
	if should_destroy:
		destroy()
		return
	
	# We had a max to our fly dist, and we've reached that? Land.
	evaluate_max_fly_dist()
	if not flying: return
	
	# We want to auto-drop on our cell? Or can't move over it?
	evaluate_current_cell()
	if not flying: return
	
	fly_further()

func evaluate_max_fly_dist():
	if fly_max_steps < 0: return
	
	# reduce by one step (lowest is 0), if still not done, continue
	fly_max_steps = max(fly_max_steps - 1, 0)
	if fly_max_steps > 0: return
	
	# can force drop here?
	var cur_cell = map.get_my_cell(self)
	if not can_drop_here(cur_cell, {'force_drop': true}): return
	
	# if we MUST stop flying, and CAN stop flying, do so
	finish_flight()

func can_drop_here(cell, params = {}):
	
	# To make PILLOWS work. (They are an ITEM, but they can stop flying items coming into the same cell, and destroy themselves in doing so)
	if cell.has_content():
		if cell.content.data.has('stops_flying_objects'): return true
		return false

	# doesn't interact with this type of cell? bail 
	if not params.has('force_drop'):
		if not cell.type in data.interact_cells: 
			return false
	else:
		if cell.data.has('can_never_hold_anything'):
			return false

	# needs a specific rotation?
	if data.has('rotation_matters') and not params.has('force_drop'):
		if not GlobalHelper.is_rotated_for_hug(cell.sprite, sprite): 
			effects_manager.create_feedback(self, "Needs hug!")
			return false

	# SPECIAL CASE => bed needs identical rotation, but only if that setting is enabled
	if cell.type == "bed":
		if GlobalDict.cfg.beds_need_correct_rotation:
			if not GlobalHelper.rotation_is_identical(sprite, cell.sprite):
				return false
	
	return true
	

func evaluate_current_cell(params = {}):
	var cell = map.get_my_cell(self)
	
	# allow specific items to stop us
	if cell.has_content() and cell.content.data.has('stops_flying_objects'): 
		GlobalAudio.play_sound(self, "pillow")
		
		cell.content.destroy()
		finish_flight()
		return

	# allow players to snatch us
	# TO DO: this only checks the first player, should I ever support multiple players? Could be nice ... 
	if cell.has_players():
		cell.get_first_player().snatch_flying_object(self)

	# or allow us to be dropped on cells if we want
	if can_drop_here(cell, params): 
		finish_flight()
	
	# otherwise, do nothing

func perform_rotation(creator, amount):
	$Sprite.rotate(amount * 0.5 * PI)

func _on_Timer_timeout():
	if in_backpack or flying: return
	
	perform_rotation(null, 1)
	
	# because this rotation is automatic, we ask the cell to see if it must update something,
	# like a player picking us up
	cur_cell.update_after_auto_rotation()

func perform_teleport():
	teleport_timer.stop()
	teleport_timer.start()

func _on_TeleportTimer_timeout():
	var new_cell = map.get_next_teleport_cell(cur_cell)
	
	if new_cell.has_content(): 
		effects_manager.create_feedback(self, "Target is occupied!")
		return
	
	cur_cell.remove_content()
	new_cell.add_content(self)




