extends Node2D

onready var map = get_node("/root/Main/Map")
onready var timer = $Timer
var settings

var num_bears = 0
var num_big_bears = 0

var item_scene = preload("res://Scenes/Item.tscn")
onready var score_manager = get_node("/root/Main/ScoreManager")
onready var effects_manager = get_node("/root/Main/EffectsManager")

var fill_up_planned = false

func _ready():
	settings = GlobalDict.cfg.bear_spawning

func activate():
	plan_fill_up()

func removed_big_bear(cell):
	num_big_bears -= 1
	
	var enable_point_gui = GlobalDict.cfg.bear_spawning.use_point_gui
	if enable_point_gui:
		var extra_points = cell.point_gui.points * GlobalDict.cfg.objective.bear_point_value_multiplier
		score_manager.update_points(cell, extra_points)
	
	effects_manager.place_particles("heart", cell)
	
	plan_fill_up()

func removed_bear():
	num_bears -= 1
	plan_fill_up()

# NOTE: we must "plan" the fill up, because removing bed and bear are two separate steps
# (Whenever one is removed, the other is NOT removed yet, which means it's not filled up properly!)
func plan_fill_up():
	fill_up_planned = true
	
	timer.stop()
	timer.wait_time = 0.05
	timer.start()

func fill_up_bears():
	while num_bears < settings.min:
		place_combo()

func place_combo():
	var area = place_tiny_bear()
	place_big_bear(area)

func place_tiny_bear():
	if num_bears >= settings.max: return -1
	
	var params = { 'default': true, 'empty': true }
	
	var most_unbalanced_area = map.get_most_unbalanced_player_area("tinybear")
	if most_unbalanced_area == null: return -2
	
	params.player_area = most_unbalanced_area
	
	var rand_cell = map.get_cell(map.get_random_pos(params))
	
	if not rand_cell: return -2
	
	var b = item_scene.instance()
	
	b.set_type("tinybear")
	b.perform_rotation(null, randi() % 4)
	
	rand_cell.add_content(b)

	num_bears += 1
	
	var player_area = GlobalHelper.get_player_from_pos(rand_cell.grid_pos)
	
	effects_manager.place_particles("star", b)
	
	return player_area

func place_big_bear(player_area : int):
	if num_big_bears >= num_bears: return
	
	var place_params = { 'default': true, 'empty': true }
	
	var new_type = "bear"
	if settings.use_beds: new_type = "bed"
	
	# no space left to place big bear
	if player_area <= -2: return
	
	var most_unbalanced_area = 0
	if player_area != -1: most_unbalanced_area = map.get_most_unbalanced_player_area(new_type, player_area)
	if most_unbalanced_area == null: return
	
	# TO DO: move this setting to bear_spawning also, so we can access it via .settings? Cleaner.
	if GlobalDict.cfg.line_up_trampolines_with_beds:
		place_params.in_line_with = ["trampoline", "shooter"] 
	
	if player_area != -1:
		if settings.keep_to_same_area:
			place_params.player_area = player_area
		else:
			place_params.forbid_player_area = player_area
			place_params.player_area = most_unbalanced_area
	
	var rand_cell = map.get_cell(map.get_random_pos(place_params))
	if not rand_cell: return # no space left to place big bear; should resolve itself after a while
	
	rand_cell.set_type(new_type)
	
	rand_cell.perform_rotation(null, randi() % 4)
	
	effects_manager.place_particles("star", rand_cell)
	
	num_big_bears += 1

func restart_timer():
	fill_up_planned = false
	
	var rand = (randf()*settings.randomness) + (1.0 - 0.5*settings.randomness)

	timer.wait_time = rand * settings.interval
	timer.start()

func _on_Timer_timeout():
	if fill_up_planned:
		fill_up_bears()
	else:
		place_combo()
	restart_timer()
