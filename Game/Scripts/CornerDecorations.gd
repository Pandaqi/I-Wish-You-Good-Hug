extends CanvasLayer

func _ready():
	if Global.in_campaign_mode():
		self.queue_free()
	
	get_tree().get_root().connect("size_changed", self, "size_changed")
	size_changed()

func size_changed():
	var real_size = GlobalHelper.get_real_screen_size()
	
	var corner_scale = 0.15
	var margin = Vector2(2048, 1536) * 0.5 * corner_scale
	var positions = [
		margin,
		Vector2(real_size.x - margin.x, margin.y),
		real_size - margin,
		Vector2(margin.x, real_size.y - margin.y)
	]
	
	for i in range(4):
		var c = get_node("Corner" + str(i+1))
		c.set_position(positions[i])
		c.set_scale(Vector2(1,1) * corner_scale)
