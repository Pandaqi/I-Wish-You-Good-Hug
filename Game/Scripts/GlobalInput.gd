extends Node

var inputs = [
	[KEY_RIGHT, KEY_DOWN, KEY_LEFT, KEY_UP, KEY_SPACE],
	[KEY_D, KEY_S, KEY_A, KEY_W, KEY_R],
	[KEY_K, KEY_J, KEY_H, KEY_U, KEY_P],
	[KEY_B, KEY_V, KEY_C, KEY_F, KEY_Z]
]

var input_order = ["right", "down", "left", "up", "rotate"]

var devices = {}
var device_order = []

var max_devices = 4

var max_joysticks = 6

func _ready():
	build_input_map()

#
# Auto-fill the input map with all the right controls
#
func build_input_map():
	var max_keyboard_players = 4
	var max_controller_players = max_joysticks # leave some room for extra connections that might be plugged in, but doing nothing
	
	for i in range(max_keyboard_players):
		
		# movement + rotating
		var id = -(i+1)
		for j in range(5):
			var key = input_order[j] + "_" + str(id)
			InputMap.add_action(key)
			
			# KEY
			var ev = InputEventKey.new()
			ev.set_scancode(inputs[i][j])
			InputMap.action_add_event(key, ev)
	
	for i in range(max_controller_players):
		
		# movement + rotating
		for j in range(5):
			var key = input_order[j] + "_" + str(i)
			InputMap.add_action(key)
			
			var ev
			
			# CONTROLLER BUTTON (any of them will do)
			# -> 10 are the buttons and shoulder stuff 
			# -> 11 and 12 are start and select
			var create_buttons = (j == 4)
			if create_buttons:
				for k in range(10):
					ev = InputEventJoypadButton.new()
					ev.button_index = k
					ev.set_device(i)
					InputMap.action_add_event(key, ev)
			
			# JOYSTICK MOTION (left and right stick)
			else:
				
				var axes = [JOY_AXIS_0, JOY_AXIS_2]
				if j % 2 == 1: axes = [JOY_AXIS_1, JOY_AXIS_3]
				
				var dir = 1
				if j >= 2: dir = -1
				
				for k in range(axes.size()):
					ev = InputEventJoypadMotion.new()
					ev.set_device(i)
					
					ev.set_axis(axes[k])
					ev.set_axis_value(dir) # <- this one determines if it's positive or negative axis
					
					InputMap.action_add_event(key, ev)
	
	# FOR DEBUGGING
	#printout_inputmap()

func printout_inputmap():
	var ac = InputMap.get_actions()
	for action in ac:
		var inputs = InputMap.get_action_list(action)
		
		for inp in inputs:
			if not (inp is InputEventJoypadMotion): continue
			
			print(inp.as_text())
			print(inp.device)

#
# Handle (un)registering input devices
#
func add_new_player(type, id = -1):
	if max_devices_reached(): return
	
	if type == 'keyboard':
		id = get_lowest_id() - 1
	
	if device_already_registered(id): return
	
	devices[id] = true
	device_order.append(id)
	
	#GlobalAudio.play_static_sound("Success")
	
	return id

func remove_player(type, id):
	if no_devices_registered(): return
	
	if type == 'keyboard' and not id:
		id = get_lowest_id()
	
	if not device_already_registered(id): return

	var index = device_order.find(id)
	
	devices.erase(id)
	device_order.remove(index)
	
	#GlobalAudio.play_static_sound("Fail")
	
	return id

func get_lowest_id():
	var min_id = 0
	for i in range(device_order.size()):
		if device_order[i] < min_id:
			min_id = device_order[i]
	
	return min_id

func no_devices_registered() -> bool:
	return (get_player_count() <= 0)

func max_devices_reached() -> bool:
	return (get_player_count() >= max_devices)

func device_already_registered(id : int) -> bool:
	return devices.has(id)

func get_player_count() -> int:
	return device_order.size()

func has_connected_device(player_num : int) -> bool:
	return player_num < device_order.size()
