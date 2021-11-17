extends Node2D


var latest_checkpoint: String
var latest_position: Vector2

func _ready():
	GameEvents.connect("checkpoint_collected", self, "register_new_checkpoint")
	pass
	
func register_new_checkpoint(args):
	var position: Vector2 = args.position
	var name: String = args.name
	
	# see if checkpoint is more advanced than current_checkpoint by comparing names
	# IMPORTANT CONVENTION: ALHABATECIALLY LARGER CHECKPOINTS ARE LATER
	if name > latest_checkpoint:
		latest_checkpoint = name
		latest_position = position
	
	
func get_checkpoint_position() -> Vector2:
	# return latest checkpoint's position
	print("move to ", latest_position, " (", latest_checkpoint, ")")
	return latest_position
