extends Node2D

const PLAYER_TOUCH_DISTANCE_THRESHOLD : float = 900.0

onready var map : Node2D = get_node("/root/Main/Map")
onready var cam : Camera2D = get_node("/root/Main/Camera")
onready var level_info : CanvasLayer = get_node("/root/Main/LevelInfo")

var player_scene : PackedScene = preload("res://Scenes/Player.tscn")
var num_players
var players = []

var touch_to_player = {}

var max_dims

func _ready():
	max_dims = map.get_dimensions()

func _process(_dt):
	if not Global.in_campaign_mode(): return
	
	# get average position + bounding rectangle around players
	var avg_pos = Vector2.ZERO
	var max_cors = Vector2(0,0)
	var min_cors = Vector2(INF, INF)
	for i in range(4):
		avg_pos += 0.25 * players[i].get_global_position()
	
	for i in range(4):
		var p = players[i].get_global_position()
		max_cors = Vector2(max(p.x, max_cors.x), max(p.y, max_cors.y))
		min_cors = Vector2(min(p.x, min_cors.x), min(p.y, min_cors.y))
	
	var dims = (max_cors - min_cors) * 2
	
	# check if one of our dimensions "maxes out" => in that case ,just use the maximum level size
	if dims.x > max_dims.x:
		avg_pos.x = 0.5*max_dims.x
		dims.x = max_dims.x

	# or  (avg_pos.x + 0.5*dims.x) > max_dims.xor (avg_pos.x - 0.5*dims.x) < 0
	#  or (avg_pos.y + 0.5*dims.y) > max_dims.y or (avg_pos.y - 0.5*dims.y) < 0

	if dims.y > max_dims.y:
		avg_pos.y = 0.5*max_dims.y
		dims.y = max_dims.y
	
	var offset = Vector2.ZERO
	if level_info.is_active():
		offset = -Vector2(cam.zoom.x * level_info.get_size(),0)
		
		avg_pos += offset
		dims += -offset

	cam.give_max_dims(max_dims, offset)
	cam.activate(dims, avg_pos)
	
	

func _unhandled_input(ev):
	var is_touch = (ev is InputEventScreenTouch)
	var is_drag = (ev is InputEventScreenDrag)

	if not (is_touch or is_drag): return

	var pos = ev.position
	var world_pos = get_canvas_transform().affine_inverse().xform(pos)
	
	var closest_player = get_closest_player_to(world_pos)
	
	if is_drag:
		if not touch_to_player.has(ev.index): return
		touch_to_player[ev.index].handle_drag_event(world_pos, ev)
		return
	
	if ev.pressed:
		if not closest_player: return
		touch_to_player[ev.index] = closest_player
		closest_player.handle_touch_event(world_pos, ev)
		return
	
	if not ev.pressed:
		if not touch_to_player.has(ev.index): return
		touch_to_player[ev.index].handle_touch_event(world_pos, ev)
		touch_to_player.erase(ev.index)
		return

func get_closest_player_to(pos):
	var closest_player = null
	var closest_dist = INF
	
	for i in range(num_players):
		var dist = (players[i].get_global_position() - pos).length()
		print(dist)
		if dist > PLAYER_TOUCH_DISTANCE_THRESHOLD: continue
		if dist > closest_dist: continue
		
		closest_dist = dist
		closest_player = players[i]
	
	return closest_player

func place_players() -> void:
	num_players = GlobalDict.cfg.num_players
	
	var start_rotations = [0,2,1,3]
	
	for i in range(num_players):
		var p = player_scene.instance()
		
		var cell = map.get_cell(GlobalHelper.get_center_of_player_half(i))
		cell.add_player(p)

		p.set_player_num(i)
		p.perform_rotation(start_rotations[i])
		
		players.append(p)
