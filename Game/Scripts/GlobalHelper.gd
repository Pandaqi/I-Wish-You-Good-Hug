extends Node

var epsilon = 0.005

func is_diagonal(vec : Vector2) -> bool:
	return abs(vec.x) > 0 and abs(vec.y) > 0

func rotation_is_identical(a : Node, b : Node) -> bool:
	var vec1 = Vector2(cos(a.get_rotation()), sin(a.get_rotation()))
	var vec2 = Vector2(cos(b.get_rotation()), sin(b.get_rotation()))

	return vec1.dot(vec2) >= (1 - epsilon)

func is_rotated_for_hug(a : Node, b : Node) -> bool:
	if a.get_parent().data.has('rotation_always_correct'): return true
	if b.get_parent().data.has('rotation_always_correct'): return true
	
	var vec1 = Vector2(cos(a.get_rotation()), sin(a.get_rotation()))
	var vec2 = Vector2(cos(b.get_rotation()), sin(b.get_rotation()))
	
	return (vec1 + vec2).length() <= epsilon
	
	# NOTE:
	# This checks for "oppsite hug" ( = 180 degrees, PI)
	# If I ever need other values, I could go via the dot product => a value of 0 is needed for quartersteps, a value of 1 for parallel, a value of -1 for the opposite hug

func is_mobile():
	return OS.get_name() == "Android" or OS.get_name() == "iOS"

func get_real_screen_size():
	var real_vp = get_viewport().size
	var vp = Vector2(1920, 1080)
	var far_x = vp.x
	var far_y = vp.y
	
	# are we blown out of proportion on the X-axis?
	# then the far-right corner should be updated as well, by the same ratio
	var diff = (real_vp.x / real_vp.y) / (vp.x / vp.y)
	if diff > 1:
		far_x *= diff
	else:
		far_y /= diff
	
	return Vector2(far_x, far_y)

# Trying something new: find the player center that's CLOSEST to
func get_player_from_pos(pos):
	var closest_player_center = -1
	var closest_dist = INF
	
	var num_players = GlobalDict.cfg.num_players
	
	for i in range(num_players):
		var dist = (get_center_of_player_half(i) - pos).length()
		if dist > closest_dist : continue
		
		closest_dist = dist
		closest_player_center = i
	
	return closest_player_center

# TO DO => feels like there's a cleaner way to do this
func get_center_of_player_half(i):
	var num_players = GlobalDict.cfg.num_players
	var map_size = GlobalDict.cfg.map_size
	
	if num_players == 1: 
		return 0.5*map_size.floor()
	
	elif num_players == 2:
		if i == 0:
			return Vector2(0.25*map_size.x, 0.5*map_size.y).floor()
		else:
			return Vector2(0.75*map_size.x, 0.5*map_size.y).floor()
	
	elif num_players == 3:
		if i == 0:
			return Vector2(0.25*map_size.x, 0.25*map_size.y).floor()
		elif i == 1:
			return Vector2(0.75*map_size.x, 0.5*map_size.y).floor()
		else:
			return Vector2(0.25*map_size.x, 0.75*map_size.y).floor()
	
	elif num_players == 4:
		if i == 0:
			return Vector2(0.25*map_size.x, 0.25*map_size.y).floor()
		elif i == 1:
			return Vector2(0.75*map_size.x, 0.25*map_size.y).floor()
		elif i == 2:
			return Vector2(0.25*map_size.x, 0.75*map_size.y).floor()
		elif i == 3:
			return Vector2(0.75*map_size.x, 0.75*map_size.y).floor()

func convert_to_star_rating(level, i):
	var data = Global.load_campaign()[level]
	var points_per_star = data.points_per_star
	
	return (i+1)*points_per_star

func get_num_stars_from_score(level, score):
	var data = Global.load_campaign()[level]
	var points_per_star = data.points_per_star
	
	return floor((score + 0.0) / points_per_star)
	
func convert_rotation_to_int(rot):
	var vec = Vector2(cos(rot), sin(rot))
	
	if vec.x > epsilon:
		return 0
	elif vec.x < -epsilon:
		return 2
	elif vec.y > epsilon:
		return 1
	else:
		return 3
