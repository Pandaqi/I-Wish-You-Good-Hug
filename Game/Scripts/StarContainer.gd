extends Control

onready var cont = $CenterContainer/VBoxContainer/HBoxContainer
onready var tween = $Tween

func fill(ind : int, score : float = -1.0):
	var level_score = score
	if level_score < 0.0:
		level_score = Global.get_save_data().data[ind]
	if not level_score: 
		level_score = 0
	
	var tween_dur = 0.3
	
	for i in range(3):
		var node = cont.get_node("Star" + str(i)).get_node("Sprite")
		
		var rating = GlobalHelper.convert_to_star_rating(ind, i)
		var filled = (level_score >= rating)
		var frame = 5 if filled else 4
		
		node.get_node("Sprite").set_frame(frame)
		node.get_node("Label").set_text(str(rating))
		
		var delay = i*tween_dur
		
		node.set_scale(Vector2.ZERO)
		node.set_modulate(Color(1,1,1,0))
		
		tween.interpolate_property(node, "scale",
		Vector2.ZERO, Vector2(1,1), 0.3,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT,
		delay)
		
		tween.interpolate_property(node, "modulate",
		Color(1,1,1,0), Color(1,1,1,1), 0.3,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT,
		delay)
	
	tween.start()
	
	get_node("CenterContainer/VBoxContainer/Highscore").set_text(str(level_score))
