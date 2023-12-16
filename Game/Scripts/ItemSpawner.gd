extends Node2D

onready var timer : Timer = $Timer
onready var map : Node2D = get_node("/root/Main/Map")
onready var effects_manager = get_node("/root/Main/EffectsManager")

var settings
var item_list
var item_scene : PackedScene = preload("res://Scenes/Item.tscn")

var num_items : int = 0

func _ready():
	settings = GlobalDict.cfg.bear_spawning
	item_list = GlobalDict.cfg.special_items

func activate():
	if item_list.size() <= 0: return
	
	_on_Timer_timeout()
	fill_up_items()

func removed_item():
	if item_list.size() <= 0: return
	fill_up_items()

func fill_up_items():
	while num_items < settings.min:
		var result = place_item()
		
		if not result: break

func place_item_of_type(creator, cell, tp):
	# cell already filled? cannot place it
	if cell.has_content(): return 
	
	var rot_as_int : int = GlobalHelper.convert_rotation_to_int(creator.get_rotation())
	
	var b = item_scene.instance()
	cell.add_content(b)
	
	# NOTE: important to ADD content first (so it's added to scene tree), before trying to do other stuff with it
	b.set_type(tp)
	b.perform_rotation(null, (rot_as_int + 2) % 4)
	
	creator.pick_up_objects()
	
	num_items += 1

func place_item():
	if num_items >= settings.max: return false
	
	var rand_type = item_list[randi() % item_list.size()]
	var params = { 'default': true, 'empty': true }
	
	var most_unbalanced_area = map.get_most_unbalanced_player_area(rand_type)
	
	if most_unbalanced_area == null: return false
	
	params.player_area = most_unbalanced_area
	
	var rand_cell = map.get_cell(map.get_random_pos(params))
	var b = item_scene.instance()
	rand_cell.add_content(b)

	b.set_type(rand_type)
	b.perform_rotation(null, randi() % 4)
	
	effects_manager.place_particles("star", b)
	
	num_items += 1
	
	return true

func reset_timer():
	var rand = (randf()*settings.randomness) + (1.0 - 0.5*settings.randomness)

	timer.wait_time = rand * settings.interval
	timer.start()

func _on_Timer_timeout():
	place_item()
	reset_timer()
