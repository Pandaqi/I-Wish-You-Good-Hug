extends Node

var MAX_NUMBER_OF_LEVELS = 100 # just to be on the safe side for future save files

var cur_level = -1
var campaign_data = null
var debugging = false

var save_data = null

var scenes = {
	"Menu": preload("res://Menu.tscn"),
	"Main": preload("res://Main.tscn")
}

func no_level_set():
	return (cur_level <= -1)

func in_campaign_mode():
	return (cur_level == 0)

func load_campaign():
	return load_json_campaign() 

func load_level(index : int) -> void:
	if not campaign_data: load_campaign()

	cur_level = index
	var level_data = campaign_data[cur_level]

	override_global_config(level_data)

func override_global_config(level_data):
	# override any settings from this in the global config
	# (we empty the config, then set all the base/default values again, then override)
	var props = level_data.props
	
	GlobalDict.cfg = {}
	for key in GlobalDict.base_cfg:
		var new_prop = GlobalDict.base_cfg[key]

		if new_prop is Array or new_prop is Dictionary:
			new_prop = str2var( var2str(new_prop) )

		GlobalDict.cfg[key] = new_prop

	deep_copy(props, GlobalDict.cfg)
	
	# can't put vector2 in JSON, so it goes via an array instead
	# TO DO: perhaps find a cleaner method for this
	if not (GlobalDict.cfg.map_size is Vector2):
		GlobalDict.cfg.map_size = Vector2(GlobalDict.cfg.map_size[0], GlobalDict.cfg.map_size[1])
	
	# EXCEPTION (the only one)
	# player count is deduced from the GlobalInput system, except on campaign (always 4)
	var num_players = GlobalInput.get_player_count()
	if props.has('override_num_players'): num_players = props.override_num_players

	GlobalDict.cfg.num_players = num_players
	
	# TESTING: make sure I can always play a keyboard player
	if num_players <= 0:
		var debug_players = 1
		for _i in range(debug_players):
			GlobalInput.add_new_player('keyboard')
		GlobalDict.cfg.num_players = debug_players
	
	# TESTING: on single player ... 
	# reduce map size by X%
	# reduce time by Y%
	var solo_mode_map_reduction = 0.75
	var solo_mode_timer_reduction = 0.75
	
	# but ONLY on the smaller maps (not after the level threshold)
	var level_threshold = 15
	
	if GlobalDict.cfg.num_players == 1 and cur_level <= level_threshold:
		var ms = GlobalDict.cfg.map_size
		GlobalDict.cfg.map_size = Vector2(floor(solo_mode_map_reduction*ms.x), floor(solo_mode_map_reduction*ms.y))
		
		var d = GlobalDict.cfg.objective.duration
		GlobalDict.cfg.objective.duration = floor(solo_mode_timer_reduction * d)

func deep_copy(from_props, to_props):
	
	for key in from_props:
		var new_prop = from_props[key]
		
		if new_prop is Array:
			new_prop = new_prop + []
		
		# it's a dictionary? go a step further, to only override the DIFFERENT values
		elif new_prop is Dictionary:
			deep_copy(new_prop, to_props[key])
			continue

		to_props[key] = new_prop

func load_json_campaign():
	if campaign_data != null: return campaign_data
	
	var path = "res://Data/campaign.json"

	campaign_data = load_json(path).campaign
	return campaign_data

func load_json(fname):
	var file = File.new()
	file.open(fname, file.READ)
	var json = file.get_as_text()
	var json_result = JSON.parse(json).result
	
	file.close()
	
	return json_result

#
# SAVE SYSTEM
#
func finish_level(score):
	if not save_data: load_game()
	
	# check score, update if better than old
	var cur_score = -1
	if save_data.data[cur_level]:
		cur_score = save_data.data[cur_level]
	
	var max_score = max(cur_score, score)
	
	save_data.data[cur_level] = max_score
	
	# check stars, unlock next level if 2+
	# but only if it's a new one, at the end of list
	var stars = GlobalHelper.get_num_stars_from_score(cur_level, score)
	
	if stars >= 2:
		var max_unlocked_level = max(save_data.last_unlocked_level, cur_level+1)
		save_data.last_unlocked_level = max_unlocked_level
	
	save_game()

func get_save_data():
	if not save_data: load_game()
	
	return save_data

func save_game(empty = false):
	var save_game = File.new()
	save_game.open(get_save_path(), File.WRITE)
	
	if empty:
		var empty_array = []
		empty_array.resize(MAX_NUMBER_OF_LEVELS)
		
		save_data = { "data": empty_array, "last_unlocked_level": 1 }

	save_game.store_line(to_json(save_data))
	save_game.close()

func get_save_path():
	return "user://savegame.save"

func load_game():
	var save_game = File.new()

	if not save_game.file_exists(get_save_path()): save_game(true)

	# otherwise, set the save_data variable immediately to the known value
	save_game.open(get_save_path(), File.READ)
	save_data = parse_json(save_game.get_line())
	save_game.close()
