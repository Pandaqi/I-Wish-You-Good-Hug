extends CanvasLayer

var active = false
var rotate_btn_scene = preload("res://Scenes/RotateBtn.tscn")
var buttons = []
var num_players

onready var menu_button_1 = get_node("MenuButton1")
onready var menu_button_2 = get_node("MenuButton2")
var menu_buttons_pressed : int = 0
var menu_buttons_visible : bool = true

onready var pause_menu = get_node("/root/Main/PauseMenu")

func destroy_menu_buttons():
	menu_button_1.queue_free()
	menu_button_2.queue_free()
	
	menu_buttons_visible = false

func _ready():
	active = GlobalHelper.is_mobile()
	
	if not active: 
		destroy_menu_buttons()
		return
	
	num_players = GlobalDict.cfg.num_players
	
	if not GlobalDict.cfg.disable_rotation_input:
		for i in range(num_players):
			var b = rotate_btn_scene.instance()
			b.my_player = i
			buttons.append(b)
			
			b.set_rotation((i % 2) * PI + 0.5*PI)
			
			add_child(b)
	
	menu_button_1.set_rotation(0.5*PI)
	menu_button_2.set_rotation(-0.5*PI)
	
	if Global.in_campaign_mode():
		destroy_menu_buttons()
	
	get_tree().get_root().connect("size_changed", self, "size_changed")
	size_changed()

func update_menu_buttons(dm):
	menu_buttons_pressed += dm
	
	if menu_buttons_pressed >= 2:
		pause_menu.open()

func size_changed():
	if not active: return
	
	var real_size = GlobalHelper.get_real_screen_size()
	
	var margin = Vector2(1,1)*120
	var positions = [Vector2.ZERO + margin, Vector2(real_size.x - margin.x, margin.y), Vector2(margin.x, real_size.y - margin.y), real_size - margin]
	
	for i in range(buttons.size()):
		buttons[i].set_position(positions[i])
	
	if menu_buttons_visible:
		menu_button_1.set_position(Vector2(margin.x, 0.5*real_size.y))
		menu_button_2.set_position(Vector2(real_size.x-margin.x, 0.5*real_size.y))
