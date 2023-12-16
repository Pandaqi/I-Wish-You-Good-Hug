extends Node2D

var point_scene : PackedScene = preload("res://Scenes/UI-Point.tscn")
var max_point_steps : int = 8
var my_cell : Node2D
var points : int = 0

var name_prefix : String = "UIPoint"

onready var ui_layer : Node2D = get_node("/root/Main/UI")

func create(cell):
	my_cell = cell
	
	for i in range(max_point_steps):
		var s = point_scene.instance()
		add_child(s)
		
		var angle = 1.5*PI + i*0.25*PI # NOTE: opposite direction from the step counter
		var vec = Vector2(cos(angle), sin(angle))
		
		s.set_position(vec * 0.5 * 512)
		s.set_rotation(angle)
		
		s.name = name_prefix + str(i)
	
	my_cell.remove_child(self)
	ui_layer.add_child(self)
	
	set_visible(true)

func update_to_cell_pos():
	set_global_position(my_cell.get_global_position())

func update_gui(dp):
	points += dp
	
	set_visible(points > 0)
	
	for i in range(max_point_steps):
		var node = get_node(name_prefix + str(i))
		node.set_visible((i < points))
