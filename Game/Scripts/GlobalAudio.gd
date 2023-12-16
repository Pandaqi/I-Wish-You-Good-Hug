extends Node


var bg_audio = preload("res://Assets/Audio/Theme.ogg")
var bg_audio_player

var audio_preload = {
	"move": [
		preload("res://Assets/Audio/move1.ogg"),
		preload("res://Assets/Audio/move2.ogg"),
		preload("res://Assets/Audio/move3.ogg"),
		preload("res://Assets/Audio/move4.ogg"),
		preload("res://Assets/Audio/move5.ogg"),
		preload("res://Assets/Audio/move6.ogg"),
		preload("res://Assets/Audio/move7.ogg"),
		preload("res://Assets/Audio/move8.ogg"),
		preload("res://Assets/Audio/move9.ogg"),
		preload("res://Assets/Audio/move10.ogg"),
		preload("res://Assets/Audio/move11.ogg"),
	],
	
	"rotate": [
		preload("res://Assets/Audio/rotate1.ogg"),
		preload("res://Assets/Audio/rotate2.ogg"),
		preload("res://Assets/Audio/rotate3.ogg"),
		preload("res://Assets/Audio/rotate4.ogg"),
		preload("res://Assets/Audio/rotate5.ogg"),
		preload("res://Assets/Audio/rotate6.ogg"),
		preload("res://Assets/Audio/rotate7.ogg"),
		preload("res://Assets/Audio/rotate8.ogg"),
		preload("res://Assets/Audio/rotate9.ogg"),
	],
	
	"game_over": [
		preload("res://Assets/Audio/game_over_loud.ogg")
	],
	
	"woosh": [
		preload("res://Assets/Audio/woosh1.ogg"),
		preload("res://Assets/Audio/woosh2.ogg"),
		preload("res://Assets/Audio/woosh3.ogg"),
		preload("res://Assets/Audio/woosh4.ogg"),
		preload("res://Assets/Audio/woosh5.ogg"),
		preload("res://Assets/Audio/woosh6.ogg"),
		preload("res://Assets/Audio/woosh7.ogg"),
		preload("res://Assets/Audio/woosh8.ogg")
		],
	
	"ploink": [
		preload("res://Assets/Audio/ploink1.ogg"), 
		#preload("res://Assets/Audio/ploink2.ogg"), 
		#preload("res://Assets/Audio/ploink3.ogg"), 
		preload("res://Assets/Audio/ploink4.ogg"),
		#preload("res://Assets/Audio/ploink5.ogg"),
		#preload("res://Assets/Audio/ploink6.ogg"),
		#preload("res://Assets/Audio/ploink7.ogg"),
		preload("res://Assets/Audio/ploink8.ogg"),
		preload("res://Assets/Audio/ploink9.ogg"),
		preload("res://Assets/Audio/ploink10.ogg"),
		preload("res://Assets/Audio/ploink11.ogg"),
		preload("res://Assets/Audio/ploink12.ogg"),
		preload("res://Assets/Audio/ploink13.ogg"),
		],
	
	"hmm": [
		preload("res://Assets/Audio/hmm1.ogg"), 
		preload("res://Assets/Audio/hmm2.ogg"), 
		preload("res://Assets/Audio/hmm3.ogg"), 
		preload("res://Assets/Audio/hmm4.ogg"), 
		preload("res://Assets/Audio/hmm5.ogg"), 
		preload("res://Assets/Audio/hmm6.ogg"), 
	],
	
	"fly": [
		preload("res://Assets/Audio/fly1.ogg"), 
		preload("res://Assets/Audio/fly2.ogg"),
	],
	
	"snore": [
		preload("res://Assets/Audio/snore1.ogg")
	],
	
	"wiehoo": [
		preload("res://Assets/Audio/wiehoo1.ogg"),
		preload("res://Assets/Audio/wiehoo2.ogg"),
		preload("res://Assets/Audio/wiehoo3.ogg"),
		preload("res://Assets/Audio/wiehoo4.ogg"),
		preload("res://Assets/Audio/wiehoo5.ogg")
	],
	
	"auw": [
		preload("res://Assets/Audio/auw1.ogg"),
		preload("res://Assets/Audio/auw2.ogg"),
		preload("res://Assets/Audio/auw3.ogg")
	],
	
	"noo": [
		preload("res://Assets/Audio/noo1.ogg"),
		preload("res://Assets/Audio/noo2.ogg"),
		preload("res://Assets/Audio/noo3.ogg"),
	],
	
	"thanks": [
		#preload("res://Assets/Audio/thanks1.ogg"), # (not clear enough)
		preload("res://Assets/Audio/thanks2.ogg"),
	],
	
	"rumble": [
		preload("res://Assets/Audio/rumble1.ogg"),
		preload("res://Assets/Audio/rumble2.ogg"),
		#preload("res://Assets/Audio/rumble3.ogg"),
		#preload("res://Assets/Audio/rumble4.ogg"),
		#preload("res://Assets/Audio/rumble5.ogg"),
		#preload("res://Assets/Audio/rumble6.ogg"),
		preload("res://Assets/Audio/rumble7.ogg"),
		preload("res://Assets/Audio/rumble8.ogg"),
		preload("res://Assets/Audio/rumble9.ogg"),
		#preload("res://Assets/Audio/rumble10.ogg"),
		preload("res://Assets/Audio/rumble11.ogg"),
	],
	
	"alarm": [
		preload("res://Assets/Audio/alarm1.ogg"),
		preload("res://Assets/Audio/alarm2.ogg"),
		preload("res://Assets/Audio/alarm3.ogg"),
	],
	
	"later": [
		preload("res://Assets/Audio/later1.ogg"),
		preload("res://Assets/Audio/later2.ogg"),
		preload("res://Assets/Audio/later3.ogg"),
	],
	
	"pillow": [
		preload("res://Assets/Audio/pillow1.ogg"),
		preload("res://Assets/Audio/pillow2.ogg"),
		preload("res://Assets/Audio/pillow3.ogg")
	]
}

func _ready():
	create_background_stream()

func create_background_stream():
	bg_audio_player = AudioStreamPlayer.new()
	add_child(bg_audio_player)
	
	bg_audio_player.bus = "BG"
	bg_audio_player.stream = bg_audio
	bg_audio_player.play()
	
	bg_audio_player.pause_mode = Node.PAUSE_MODE_PROCESS

func play_static_sound(key, volume_alteration = 0):
	var wanted_audio = audio_preload[key]
	if wanted_audio is Array: wanted_audio = wanted_audio[randi() % wanted_audio.size()]
	
	var audio_player = AudioStreamPlayer.new()
	audio_player.bus = "GUI"
	audio_player.volume_db = volume_alteration
	audio_player.connect("finished", audio_player, "queue_free")
	
	add_child(audio_player)
	
	audio_player.stream = wanted_audio
	audio_player.play()
	
	audio_player.pause_mode = Node.PAUSE_MODE_PROCESS

func play_static_effect_sound(key, volume_alteration = 0):
	var wanted_audio = audio_preload[key]
	if wanted_audio is Array: wanted_audio = wanted_audio[randi() % wanted_audio.size()]
	
	var audio_player = AudioStreamPlayer.new()
	audio_player.bus = "FX"
	audio_player.volume_db = volume_alteration
	audio_player.connect("finished", audio_player, "queue_free")
	
	add_child(audio_player)
	
	audio_player.stream = wanted_audio
	audio_player.play()
	
	audio_player.pause_mode = Node.PAUSE_MODE_PROCESS

func play_sound(creator, key, volume_alteration = 0):
	var wanted_audio = audio_preload[key]
	
	# if it's a LIST of effects, pick one at random
	if wanted_audio is Array:
		wanted_audio = wanted_audio[randi() % wanted_audio.size()]
	
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.max_distance = 10000000
	audio_player.bus = "FX"
	audio_player.volume_db = volume_alteration
	audio_player.set_position(creator.get_global_position())
	audio_player.connect("finished", audio_player, "queue_free")
	
	add_child(audio_player)
	
	audio_player.stream = wanted_audio
	audio_player.play()
