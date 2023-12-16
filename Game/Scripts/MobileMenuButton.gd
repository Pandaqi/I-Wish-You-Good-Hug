extends Node2D

onready var gui_mobile = get_node("/root/Main/GUIMobile")

var touches = []
var active = false

func _ready():
	modulate.a = 0.3

func press(ev):
	if ev.pressed:
		touches.append(ev.index)
		activate()
	else:
		touches.erase(ev.index)
		deactivate()

func activate():
	if active: return
	
	modulate.a = 1.0
	
	active = true
	gui_mobile.update_menu_buttons(1)

func deactivate():
	if touches.size() > 0: return
	
	modulate.a = 0.3
	
	active = false
	gui_mobile.update_menu_buttons(-1)
