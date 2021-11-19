extends Node2D

signal grass_rustle

func _ready() -> void:
	connect("grass_rustle", self, "grass_rustle")
	
onready var grass_players := [$GrassPlayers/Grass1, $GrassPlayers/Grass2, $GrassPlayers/Grass3]
func grass_rustle():
	for player in grass_players:
		var audio = player as AudioStreamPlayer
		if audio.playing:
			continue
		else:
			audio.play()
			return
	# all audio players busy at the moment
		
