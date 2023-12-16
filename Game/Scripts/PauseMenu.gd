extends CanvasLayer

var active : bool = false
onready var control = $Control

onready var first_btn = $Control/CenterContainer/VBoxContainer/Restart

func _ready():
	self.close()

func open():
	get_tree().paused = true
	control.set_visible(true)
	active = true
	
	first_btn.grab_focus()

func close():
	get_tree().paused = false
	control.set_visible(false)
	active = false

func _input(ev):
	if Global.in_campaign_mode(): return
	
	if not active:
		if ev.is_action_released("open_pause_menu"):
			self.open()
	else:
		if ev.is_action_released("close_pause_menu"):
			self.close()

func _on_Restart_pressed():
	GlobalAudio.play_static_sound("ploink")
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_Back_pressed():
	GlobalAudio.play_static_sound("ploink")
	get_tree().paused = false
	
	if not Global.in_campaign_mode():
		Global.load_level(0)
		get_tree().reload_current_scene()
	
	else:
		get_tree().change_scene_to(Global.scenes.Menu)

func _on_Close_pressed():
	GlobalAudio.play_static_sound("ploink")
	self.close()
