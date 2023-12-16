extends Node2D

onready var time = $Time
onready var s1 = $Score1
onready var s2 = $Score2

func set_level_index(i : int):
	var string = str(i)
	
	s1.set_text(string)
	s2.set_text(string)
	time.set_text(string)

func set_points(p : int) -> void:
	s1.set_text(str(p))
	s2.set_text(str(p))

func set_time(t : String) -> void:
	time.set_text(t)
