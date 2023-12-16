extends Node2D

func set_feedback(txt, good = false):
	modulate = Color(1,0.5,0.5)
	if good:
		modulate = Color(0.5,1,0.5)
	
	get_node("Label").set_text(str(txt))

func kill():
	self.queue_free()
