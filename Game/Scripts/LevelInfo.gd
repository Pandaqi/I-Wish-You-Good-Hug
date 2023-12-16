extends CanvasLayer

onready var heading = $Control/MarginContainer/ColorRect/MarginContainer/VBoxContainer/Heading
onready var desc = $Control/MarginContainer/ColorRect/MarginContainer/VBoxContainer/Desc
onready var stars = $Control/MarginContainer/ColorRect/MarginContainer/VBoxContainer/Stars
onready var control = $Control
onready var instruction = $Control/MarginContainer/ColorRect/MarginContainer/VBoxContainer/Instruction

onready var exit_btn_cont = $MarginContainer
onready var player_manager = get_node("/root/Main/PlayerManager")

var active : bool = false

var cur_level_selected : int = -1

func _ready():
	control.set_visible(false)
	control.modulate.a = 0.0
	
	if not Global.in_campaign_mode():
		exit_btn_cont.queue_free()
	else:
		if GlobalHelper.is_mobile():
			exit_btn_cont.get_node("HBoxContainer/Label").queue_free()

func is_active():
	return active

func get_size():
	return max(control.rect_min_size.x, control.rect_size.x)

func fill_info(level_index, info):
	heading.set_text(info.name)
	desc.set_text(info.desc)
	
	active = true
	
	if not control.is_visible():
		$AnimationPlayer.play("FadeIn")
	
	control.set_visible(true)
	
	cur_level_selected = level_index
	stars.fill(level_index)
	
	var string = "(Move all players to this level to start)"
	
	if GlobalInput.get_player_count() == 1:
		string = "(Press anything to start)"
	
		if GlobalHelper.is_mobile(): 
			string = "(Tap here to start)"
	
	instruction.set_text(string)

func _on_Exit_pressed():
	GlobalAudio.play_static_sound("ploink")
	get_tree().change_scene_to(Global.scenes.Menu)

func load_first_player_campaign_cell():
	var cur_cell = player_manager.players[0].cur_cell
	if cur_cell.matching_level_index <= 0: return false
	
	Global.load_level(cur_cell.matching_level_index)
	get_tree().reload_current_scene()
	
	return true

func _input(ev):
	if not Global.in_campaign_mode(): return
	
	if ev.is_action_released("back_to_menu"):
		_on_Exit_pressed()
		return
	
	if GlobalInput.get_player_count() == 1:
		var pressed_something = (ev is InputEventKey or ev is InputEventJoypadButton)
		
		if not pressed_something: return
		if ev.pressed: return
		
		var is_move_action = (ev.is_action_released("left_-1") or ev.is_action_released("right_-1") or ev.is_action_released("up_-1") or ev.is_action_released("down_-1"))
		
		if is_move_action: return
		
		var success = load_first_player_campaign_cell()
		if success: get_tree().set_input_as_handled()

func _on_TouchScreenButton_released():
	if GlobalInput.get_player_count() != 1: return
	
	load_first_player_campaign_cell()
