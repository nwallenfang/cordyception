extends Node2D

signal grass_rustle

var combat := false  # if true play combat music else play ambient music
const fadeout_duration: float = 4.5
const psych_fadein := 4.5
const combat_max_volume := -5.9
const ambient_max_volume := -8.8
const psychedelic_max_volume := -5.9

const stage_base_volume := -7
const stage_dialog_volume := -13

onready var tween_out := $TweenOut as Tween
onready var tween_in := $TweenIn as Tween

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
	
func switch_music():
	tween_in.reset_all()
	tween_out.reset_all()
	
	if combat:
		$Ambient.play(rand_range(0, $Ambient.stream.get_length()))
	else:
		$Combat.play()
	
	
	if combat:
		# fade combat music out and ambient music in
		print("fade combat music out and ambient music in")
		tween_out.interpolate_property($Combat, "volume_db", combat_max_volume, -80, fadeout_duration, Tween.TRANS_CIRC, Tween.EASE_IN, 0)
		tween_in.interpolate_property($Ambient, "volume_db", -80, ambient_max_volume, fadeout_duration, Tween.TRANS_CIRC, Tween.EASE_OUT, 0)
	else:
		# fade ambient music in and combat out
		print("fade ambient music in and combat out")
		tween_out.interpolate_property($Ambient, "volume_db", ambient_max_volume, -80, fadeout_duration, Tween.TRANS_CIRC, Tween.EASE_IN, 0)
		tween_in.interpolate_property($Combat, "volume_db", -80, combat_max_volume, fadeout_duration, Tween.TRANS_CIRC, Tween.EASE_OUT, 0)

	combat = not combat

	tween_out.start()
	tween_in.start()
		
func is_music_playing():
	return $Ambient.playing or $Combat.playing or $Psychedelic.playing

func switch_to_psychedelic():
	tween_in.reset_all()
	tween_out.reset_all()
#	if combat:
#		tween_out.interpolate_property($Combat, "volume_db", combat_max_volume, -80, fadeout_duration, Tween.TRANS_CIRC, Tween.EASE_IN, 0)
#	else:
#		tween_out.interpolate_property($Ambient, "volume_db", ambient_max_volume, -80, fadeout_duration, Tween.TRANS_CIRC, Tween.EASE_IN, 0)

	tween_in.interpolate_property($Psychedelic, "volume_db", -80, psychedelic_max_volume, psych_fadein, Tween.TRANS_CIRC, Tween.EASE_OUT, 0)
	tween_in.start()
#	tween_out.start()
	$Psychedelic.play()
	
func switch_back_from_psychdelic():
	tween_in.reset_all()
	tween_out.reset_all()

#	if combat:
#		$Combat.play()
#		tween_in.interpolate_property($Combat, "volume_db", -80, combat_max_volume, fadeout_duration, Tween.TRANS_CIRC, Tween.EASE_OUT, 0)
#	else:
#		$Ambient.play()
#		tween_in.interpolate_property($Ambient, "volume_db", -80, ambient_max_volume, fadeout_duration, Tween.TRANS_CIRC, Tween.EASE_OUT, 0)
	tween_out.interpolate_property($Psychedelic, "volume_db", psychedelic_max_volume, -80, fadeout_duration, Tween.TRANS_CIRC, Tween.EASE_IN, 0)
	
#	tween_in.start()
	tween_out.start()
	
func stop_music():
	tween_out.reset_all()
	if $Psychedelic.playing:
		tween_out.interpolate_property($Psychedelic, "volume_db", psychedelic_max_volume, -80, fadeout_duration, Tween.TRANS_CIRC, Tween.EASE_IN, 0)
	elif $Stage.playing:
		tween_out.interpolate_property($Stage, "volume_db", stage_base_volume, -80, fadeout_duration, Tween.TRANS_CIRC, Tween.EASE_IN, 0)
	if combat:
		tween_out.interpolate_property($Combat, "volume_db", combat_max_volume, -80, fadeout_duration, Tween.TRANS_CIRC, Tween.EASE_IN, 0)
	else:
		tween_out.interpolate_property($Ambient, "volume_db", ambient_max_volume, -80, fadeout_duration, Tween.TRANS_CIRC, Tween.EASE_IN, 0)
	tween_out.start()
	
func stop_stage_music():
	tween_out.reset_all()
	tween_out.interpolate_property($Stage, "volume_db", stage_dialog_volume, -80, fadeout_duration, Tween.TRANS_CIRC, Tween.EASE_IN, 0)
	tween_out.start()
	
func start_music():
	if combat:
		tween_in.interpolate_property($Combat, "volume_db", -80, combat_max_volume, fadeout_duration, Tween.TRANS_CIRC, Tween.EASE_OUT, 0)
		$Combat.play()
	else:
		tween_in.interpolate_property($Ambient, "volume_db", -80, ambient_max_volume, fadeout_duration, Tween.TRANS_CIRC, Tween.EASE_OUT, 0)
		$Ambient.play(rand_range(0, $Ambient.stream.get_length()))
	tween_in.start()
		

func start_stage_music():
	tween_out.interpolate_property($Combat, "volume_db", combat_max_volume, -80, fadeout_duration, Tween.TRANS_SINE, Tween.EASE_IN, 0)
	$Stage.play()
	tween_in.reset_all()
	tween_in.interpolate_property($Stage, "volume_db", -12, stage_dialog_volume, fadeout_duration, Tween.TRANS_SINE, Tween.EASE_OUT, 0)
	tween_in.start()
	tween_out.start()
	

func _on_TweenOut_tween_completed(object: Object, key: NodePath) -> void:
	if object is AudioStreamPlayer:
		object.stop()
	else:
		print("ERROR SOMETHING WEIRD IN TWEEN COMPLETED ", object)
