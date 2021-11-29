extends AbstractState

export var IDLE_TIME_MIN := 0.3
export var IDLE_TIME_MAX := 0.8

var moved_up = false

func _ready() -> void:
	# you will only transition to Idle explicitly
	parent = parent as StagBeetle

func move_up():
	pass

func move_down():
	pass

func process(delta, first_time_entering):
	if first_time_entering:
		pass
	
	if moved_up:
		# move down
		pass
		
	
	# TODO if moved up the behavior should be different
	# maybe no melee attacks and more projectiles instead
