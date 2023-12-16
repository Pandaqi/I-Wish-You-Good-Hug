extends Node2D

var bubbles = []
var input_bubble_scene = preload("res://Scenes/InputBubble.tscn")


var active = false
var bubble_offset = -512

var keep_bubbles_above_head : bool = true

onready var player_manager = get_node("/root/Main/PlayerManager")

func activate():
	active = true
	create_input_bubbles()
	check_player_disabledness()

func create_input_bubbles():
	for i in range(4):
		var b = input_bubble_scene.instance()
		add_child(b)
		
		bubbles.append(b)
		
		if GlobalHelper.is_mobile() and not keep_bubbles_above_head:
			b.set_rotation((i % 2) * PI + 0.5*PI)

func check_player_disabledness():
	for i in range(4):
		if GlobalInput.has_connected_device(i): 
			player_manager.players[i].enable()
		else:
			player_manager.players[i].disable()

func _unhandled_input(ev):
	if not active: return
	
	# check if any joystick buttons are pressed; register those devices
	# NOTE: GlobalInput ignores this if the controller was already registered, no probs
	for i in range(GlobalInput.max_joysticks):
		if not (ev is InputEventJoypadButton): continue
		if not ev.is_action_released("rotate_" + str(i)): continue
	
		GlobalInput.add_new_player('joystick', ev.device)
		check_player_disabledness()
	
	# check if keyboard players want to be added/removed
	if ev.is_action_released("add_new_keyboard_player"):
		GlobalInput.add_new_player('keyboard')
		check_player_disabledness()
	
	elif ev.is_action_released("remove_last_keyboard_player"):
		GlobalInput.remove_player('keyboard', null)
		check_player_disabledness()

func _process(_dt):
	if not active: return
	
	var players = player_manager.players

	for i in range(4):
		var p = players[i]
		var b = bubbles[i]
		
		var is_visible = i <= GlobalInput.get_player_count()
		b.set_visible(is_visible)
		
		var offset_dir = Vector2(cos(b.get_rotation()+0.5*PI), sin(b.get_rotation()+0.5*PI))
		var final_offset = offset_dir * bubble_offset

		b.set_global_position(p.get_global_position() + final_offset)
		b.update_frame(i)
