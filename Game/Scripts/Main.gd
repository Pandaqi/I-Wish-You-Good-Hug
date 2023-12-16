extends Node2D

onready var map : Node2D = $Map
onready var cam : Camera2D = $Camera
onready var player_manager : Node2D = $PlayerManager
onready var spawner : Node2D = $Spawner
onready var item_spawner : Node2D = $ItemSpawner
onready var score_manager : Node2D = $ScoreManager
onready var input_manager: Node2D = $InputManager
onready var level_info : CanvasLayer = $LevelInfo
onready var tutorial : CanvasLayer = $Tutorial

onready var game_over_menu : CanvasLayer = $GameOverMenu

var override_level : int = -1

# NOTE: Export var values are NOT read yet when this function is called (so I need to set override_level manually)
func _init():
	# only load our override level, if nothing was set from global
	if Global.no_level_set():
		Global.load_level(override_level)

func _ready():
	if Global.in_campaign_mode():
		load_campaign_level()
	else:
		load_regular_level()

func load_campaign_level():
	map.create_base_map()
	player_manager.place_players()
	
	map.create_campaign_map()
	
	input_manager.activate()
	
	cam.give_max_dims(map.get_dimensions())
	cam.activate(map.get_dimensions(), Vector2.ZERO)
	cam.hard_set_offset()

func load_regular_level():
	map.create_base_map()
	player_manager.place_players()
	
	map.populate_map()
	spawner.activate()
	item_spawner.activate()
	score_manager.activate()
	
	cam.activate(map.get_dimensions(), Vector2.ZERO)
	cam.hard_set_offset()
	
	input_manager.queue_free()
	level_info.queue_free()
	
	tutorial.activate()

func game_over():
	map.animate_the_whole_field()
	
	GlobalAudio.play_static_effect_sound("game_over")
	
	var string = "You scored " + str(score_manager.points) + " points! Well done!" 
	game_over_menu.fill_info(string)
	game_over_menu.open(score_manager.points)

func update_level_info(level_index : int):
	var info = Global.load_campaign()[level_index]
	level_info.fill_info(level_index, info)
