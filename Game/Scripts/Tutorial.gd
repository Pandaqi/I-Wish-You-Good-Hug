extends CanvasLayer

var tut_images = []
var counter = -1
var active = false

onready var tut_node = $Control/MarginContainer/Content
onready var label = $Control/MarginContainer/Control/Label

onready var timer = $Timer

func _ready():
	$Control.set_visible(false)

func _input(ev):
	if not active: return
	if timer.time_left > 0: return

	var press = (ev is InputEventKey or ev is InputEventJoypadButton or ev is InputEventScreenTouch or ev is InputEventMouseButton)
	
	if not press: return
	if ev.pressed: return
	
	get_tree().set_input_as_handled()
	load_next_image()

func toggle_active(val):
	active = val
	get_tree().paused = val
	$Control.set_visible(val)

func activate():
	var imgs = GlobalDict.cfg.tutorial
	if imgs.size() <= 0: return
	
	tut_images = imgs
	
	# EXCEPTION: On mobile, the pause menu is opened with a special mechanism
	#			 that needs some explanation (but desktop does not)
	if GlobalHelper.is_mobile() and "Rotator" in tut_images:
		tut_images.append("PauseMenuMobile")
	
	toggle_active(true)
	
	counter = -1
	load_next_image()

func load_next_image():
	counter += 1
	
	if counter >= tut_images.size():
		toggle_active(false)
		return
	
	var image_name = tut_images[counter]
	
	# EXCEPTION: Mobile has different controls for moving/throwing/pausing, 
	# 			 all other tutorials are identical
	if GlobalHelper.is_mobile():
		if image_name in ["Move", "Rotate", "PauseMenu"]:
			image_name += "Mobile"
	
	var path = "res://Assets/Tutorials/" + image_name + ".png"
	tut_node.texture = load(path)
	
	var label_val = "(Tap/Press any to continue) (" + str(counter+1) + "/" + str(tut_images.size()) + ")"
	label.set_text(label_val)
	
	timer.start()

func _on_Timer_timeout():
	pass # Replace with function body.
