extends Node2D


# for stuff that can or should happen across or outside of Acts
func _ready():
	GameEvents.connect("player_died", self, "player_died")

func player_died():
	var player = GameStatus.CURRENT_PLAYER as Player	
	player.global_position = $CheckpointManager.get_checkpoint_position()
	# reset player (HP etc.)
	player.reset()
	# reset current act
	GameStatus.CURRENT_ACT.reset()
