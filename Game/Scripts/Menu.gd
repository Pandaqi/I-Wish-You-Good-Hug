extends Node2D

onready var settings_menu = $Settings
onready var menu = $Menu/Control
onready var first_btn = $Menu/Control/CenterContainer/VBoxContainer/VBoxContainer/Play

func _ready():
	focus_on_first_btn()

func focus_on_first_btn():
	first_btn.grab_focus()

func _on_Play_pressed():
	GlobalAudio.play_static_sound("ploink")
	Global.load_level(0)
	get_tree().change_scene_to(Global.scenes.Main)

func hide():
	menu.set_visible(false)

func show():
	menu.set_visible(true)
	focus_on_first_btn()

func _on_Settings_pressed():
	GlobalAudio.play_static_sound("ploink")
	self.hide()
	settings_menu.show()

func _on_Exit_pressed():
	GlobalAudio.play_static_sound("ploink")
	get_tree().quit()
