extends CanvasLayer

var active : bool = false
var allow_input : bool = false

onready var control = $Control
onready var effects_tween = get_node("/root/Main/EffectsTween")
onready var timer = $Timer

onready var first_btn = $Control/CenterContainer/VBoxContainer/HBoxContainer/Continue

onready var body_txt = $Control/CenterContainer/VBoxContainer/Body
onready var stars = $Control/CenterContainer/VBoxContainer/Stars

func _ready():
	self.close()

func fill_info(txt):
	body_txt.set_text(str(txt))

func open(points : float):
	control.modulate = Color(1,1,1,0)
	
	get_tree().paused = true
	control.set_visible(true)
	active = true
	
	var appear_tween_duration = 1.6
	
	effects_tween.interpolate_property(control, "modulate",
	control.modulate, Color(1,1,1,1), appear_tween_duration,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	effects_tween.start()
	
	first_btn.grab_focus()
	
	stars.fill(Global.cur_level, points)
	
	timer.start()

func close():
	get_tree().paused = false
	control.set_visible(false)
	active = false

func _input(ev):
	if not active: return
	if not allow_input: return
	
	if ev.is_action_released("gameover_restart"):
		_on_Restart_pressed()
		return
	
	if ev is InputEventKey or ev is InputEventJoypadButton:
		_on_Continue_pressed()
	
func _on_Restart_pressed():
	GlobalAudio.play_static_sound("ploink")
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_Continue_pressed():
	GlobalAudio.play_static_sound("ploink")
	get_tree().paused = false
	Global.load_level(0)
	get_tree().reload_current_scene()

func _on_Timer_timeout():
	allow_input = true
