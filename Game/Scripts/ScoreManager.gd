extends Node2D

var points : int = 0
var time : int = 0

onready var timer = $Timer
onready var map = get_node("/root/Main/Map")
onready var main_node = get_node("/root/Main")
onready var effects_manager = get_node("/root/Main/EffectsManager")
var score_gui

func activate():
	time = GlobalDict.cfg.objective.duration
	score_gui = map.score_cell.score_gui
	
	update_points(null, 0)
	update_time(0)
	
	timer.start()

func convert_time_to_string():
	var minutes = floor(time / 60.0)
	var seconds = time % 60
	
	if minutes < 10: minutes = "0" + str(minutes)
	if seconds < 10: seconds = "0" + str(seconds)
	
	return str(minutes) + ":" + str(seconds)

func update_points(creator, dp):
	if GlobalInput.get_player_count() == 1: 
		dp = round(dp*GlobalDict.cfg.solo_player_point_multiplier)
	
	points = clamp(points + round(dp), 0, INF)
	score_gui.set_points(points)
	
	if not creator: return
	if dp == 0: return
	
	var string = "+" + str(dp)
	var good = true
	if dp < 0: 
		string = str(dp)
		good = false
	string += " points!"
	
	effects_manager.create_feedback(creator, string, good)

func update_time(dt):
	time += dt
	score_gui.set_time(convert_time_to_string())

func _on_Timer_timeout():
	update_time(-1)
	
	if time <= 0: end_the_game()

func end_the_game():
	Global.finish_level(points)
	main_node.game_over()
