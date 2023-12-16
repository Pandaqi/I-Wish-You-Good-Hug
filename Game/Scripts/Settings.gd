extends CanvasLayer

onready var cont = $Control/CenterContainer/VBoxContainer

var setting_module_scene = preload("res://Scenes/SettingsModule.tscn")
var modules = []

func _ready():
	create_interface()
	hide()

func hide():
	$Control.set_visible(false)

func show():
	$Control.set_visible(true)
	grab_focus_on_first()

func grab_focus_on_first():
	modules[0].grab_focus_on_comp()

func create_interface():
	var st = GlobalConfig.settings
	
	for i in range(st.size()):
		var cur_setting = st[i]
		var node = setting_module_scene.instance()
		
		# set correct name and section,
		# so it knows WHICH entries to update
		node.initialize(cur_setting)
		
		# set to the current saved value in the config
		node.update_to_config()
		
		# add the whole thing
		cont.add_child(node)
		modules.append(node)
	
	# make sure the back button is at the BOTTOM
	var back_btn = cont.get_node("Back")
	cont.remove_child(back_btn)
	cont.add_child(back_btn)

func _on_Back_pressed():
	GlobalAudio.play_static_sound("ploink")
	
	self.hide()
	get_node("/root/Main").show()
