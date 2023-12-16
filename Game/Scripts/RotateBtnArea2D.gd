extends Area2D

onready var btn = get_node("..")

func _input_event(_viewport, ev, _shape_idx):
	if not ev is InputEventScreenTouch: return
	btn.press(ev)
	
	get_tree().set_input_as_handled()
