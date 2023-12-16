extends Node2D

var fingers_pressed = []
var active : bool = false
var my_player : int = -1

onready var player_manager = get_node("/root/Main/PlayerManager")

func activate():
	if active: return
	
	active = true
	player_manager.players[my_player].start_rotating()

func deactivate():
	if not active: return
	active = false
	player_manager.players[my_player].stop_rotating()

func _on_TouchScreenButton_pressed():
	activate()

func _on_TouchScreenButton_released():
	deactivate()
