extends Camera2D

var dims : Vector2
var c_off : Vector2

var base_res = Vector2(1920, 1080)
var edge_margin = 512*0.66

var active = false

func give_max_dims(max_dims : Vector2, max_offset : Vector2 = Vector2.ZERO):
	limit_left = max_offset.x -edge_margin
	limit_right = max_dims.x + edge_margin
	
	limit_top = max_offset.y -edge_margin
	limit_bottom = max_dims.y + edge_margin

func activate(dimensions : Vector2, center_offset : Vector2):
	dims = dimensions
	c_off = center_offset
	
	active = true

func _process(dt):
	if not active: return
	
	center_on_level()

func hard_set_offset():
	set_position(dims*0.5)

func center_on_level():
	var center = dims*0.5
	if c_off.length() > 0.05: center = c_off
	
	var lerped_center = lerp(get_position(), center, 0.05)
	set_position(lerped_center)

	var vp = base_res
	var min_zoom = min(vp.x / (dims.x+2*edge_margin), vp.y / (dims.y+2*edge_margin))
	var new_zoom = Vector2(1,1) * (1.0/min_zoom)
	
	var lerped_zoom = lerp(zoom, new_zoom, 0.05)
	
	set_zoom(lerped_zoom)
