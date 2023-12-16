extends Node2D

onready var sprite = $Sprite

func update_frame(index : int) -> void:
	var devices = GlobalInput.device_order
	var is_mobile = GlobalHelper.is_mobile()
	
	# input waiting
	var not_registered = (index >= devices.size())
	if not_registered:
		modulate.a = 0.7
		
		if is_mobile:
			sprite.set_frame(6)
		else:
			sprite.set_frame(5)
		return
	
	modulate.a = 1.0
	
	# touch controlled
	if is_mobile:
		sprite.set_frame(12)
		return
	
	# keyboard controlled; keys depend on WHICH keyboard player it is
	var device_id = devices[index]
	if device_id < 0:
		sprite.set_frame(7 + abs(device_id))
		return
	
	# joystick controlled
	sprite.set_frame(7)
