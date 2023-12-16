extends Node2D

onready var fb_txt = preload("res://Scenes/FeedbackText.tscn")
var particle_scenes = {
	"star": preload("res://Scenes/StarParticles.tscn"),
	"heart": preload("res://Scenes/HeartParticles.tscn"),
	"arrow": preload("res://Scenes/ArrowParticles.tscn"),
	"rotate": preload("res://Scenes/RotateParticles.tscn")
}

func place_particles(type, creator, params = {}):
	var s = particle_scenes[type].instance()
	s.set_position(creator.get_global_position())

	if params.has('rotation'): s.set_rotation(params.rotation)

	add_child(s)
	
	if type == "rotate": 
		s.set_emitting(true)
		s.local_coords = true
		s.set_scale(Vector2(1,1)*(1.0+randf()*0.66))

func create_feedback(creator, txt, good = false):
	var is_player = creator.is_in_group("Players")
	if is_player and creator.feedback_disabled: return
	
	var fb = fb_txt.instance()
	fb.set_global_position(creator.get_global_position())
	fb.set_feedback(txt, good)
	
	add_child(fb)
	
	if is_player: creator.disable_feedback()
