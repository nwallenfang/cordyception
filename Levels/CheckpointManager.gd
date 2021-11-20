extends Node2D


var latest_checkpoint: String
var latest_position: Vector2
var latest_event_dict: Dictionary = {}

# for stuff that can or should happen across or outside of Acts
func _ready():
	GameEvents.connect("player_died", self, "player_died")
	GameEvents.connect("checkpoint_collected", self, "register_new_checkpoint")

func player_died():

	# Start camera fadeout
	GameStatus.CURRENT_CAMERA.fade_out()
	yield(GameStatus.CURRENT_CAMERA, "fade_out_finished")
	# call_deferred("reset") -> old reset call
	# after fadeout, transition
	get_tree().reload_current_scene()
	call_deferred("reset")
	# fadein
	GameStatus.CURRENT_CAMERA.fade_in()
	yield(GameStatus.CURRENT_CAMERA, "fade_in_finished")


func reset():
	var checkpoint: Dictionary = get_latest_checkpoint()
	# reset player (HP etc.)
	# player.reset()
	# reset current act
	# GameStatus.CURRENT_ACT.reset()
	# reset Game Events
	# all resets are useless because the scene is reloaded anyways
	GameEvents.EVENT_COUNTER = checkpoint.events.duplicate(true)
	
	var player = GameStatus.CURRENT_PLAYER as Player
	player.global_position = checkpoint.position

func _process(delta):
	# for debugging
	if Input.is_action_just_pressed("kill_player"):
		GameStatus.CURRENT_HEALTH = 0
	
func register_new_checkpoint(args):
	var position: Vector2 = args.position
	var name: String = args.name
	var event_dictionary = args.current_events
	
	# see if checkpoint is more advanced than current_checkpoint by comparing names
	# IMPORTANT CONVENTION: ALHABATECIALLY LARGER CHECKPOINTS ARE LATER
	if name > latest_checkpoint:
		latest_checkpoint = name
		latest_position = position
		latest_event_dict = event_dictionary.duplicate(true)

		print("new checkpoint ", name, " registered as latest")
	else:
		print("new checkpoint ", name, " older than latest ", latest_checkpoint)
	
	
func get_latest_checkpoint() -> Dictionary:
	# return latest checkpoint's position
	print("move to ", latest_position, " (", latest_checkpoint, ")")
	return {"position": latest_position, "events": latest_event_dict}
