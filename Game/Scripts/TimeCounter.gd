extends Node2D

var ui_sand_timer_scene = preload("res://Scenes/UI-SandTimer.tscn")

var num_time_steps : int = 0
var max_time_steps : int = 8 # => again, TO DO, read from global config?

onready var ui_layer = get_node("/root/Main/UI")
onready var timer = $Timer
onready var arrow = $Arrow
onready var tween = $Tween

var my_cell
var data

func stop():
	timer.stop()

func reset() -> void:
	data = GlobalDict.cells[my_cell.type]
	num_time_steps = data.timing.steps
	
	timer.stop()
	timer.wait_time = data.timing.interval
	timer.start()
	
	update_gui()

func handle_manual_rotation():
	pop_up_arrow_for_clarity()
	
func pop_up_arrow_for_clarity():
	if not arrow: return
	
	var regular_scale = 0.25*Vector2(1,1)
	var large_scale = regular_scale * 4.0
	
	tween.stop_all()
	
	arrow.set_scale(large_scale)
	
	tween.interpolate_property(arrow, "scale", 
		large_scale, regular_scale, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func rewind():
	if not GlobalDict.cfg.can_rewind_timers: return
	
	update_steps(1)

func update_steps(ds : int):
	num_time_steps = clamp(num_time_steps + ds, 0, max_time_steps)
	update_gui()
	
	if num_time_steps <= 0:
		my_cell.timeout_activation()
		reset()

func create(cell):
	my_cell = cell

	for i in range(max_time_steps):
		var s = ui_sand_timer_scene.instance()
		add_child(s)
		
		var angle = 1.5*PI + i*0.25*PI # NOTE: opposite direction from the step counter
		var vec = Vector2(cos(angle), sin(angle))
		
		s.set_position(vec * 0.5 * 512)
		s.set_rotation(angle)
		
		s.name = "UISandTimer" + str(i)
	
	my_cell.remove_child(self)
	ui_layer.add_child(self)
	
	set_visible(false)

func update_to_cell_pos():
	set_global_position(my_cell.get_global_position())

func update_arrow():
	arrow.set_visible( data.has('gui_also_shows_rotation') )

	var rot = my_cell.sprite.get_rotation()
	arrow.set_rotation(rot)

	var radius = 270
	var vec = Vector2(cos(rot), sin(rot))
	arrow.set_position(vec * radius)

func update_gui():
	data = GlobalDict.cells[my_cell.type]
	
	update_to_cell_pos()
	update_arrow()
	
	for i in range(max_time_steps):
		var node = get_node("UISandTimer" + str(i))
		node.set_visible((i < num_time_steps))

func _on_Timer_timeout():
	update_steps(-1)
