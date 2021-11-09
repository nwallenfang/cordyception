extends Node2D

const MAX_SPRINT_DISTANCE := 500
export var SPRINT_VELOCITY := 400
export var SPRINT_DELAY := 0.4

func _ready() -> void:
	# check if SprintSkill 
	pass

func begin_sprinting(delta: float):
	var direction = $Line2D.points[1].angle() + PI/2
	var distance_to_player = ($Line2D.points[1] - $Line2D.points[0]).length()
	
	# 1. if this enemy is too far from the player, don't sprint
	if distance_to_player > MAX_SPRINT_DISTANCE:
		transition_to(State.IDLE)
		return
	
	# 2. see if there is line of sight towards the player
	# cast a ray between Enemy and player for this
	var space_state = get_world_2d().direct_space_state
	var ray_result = space_state.intersect_ray(self.global_position, GameStatus.CURRENT_PLAYER.global_position)
	
	if not ray_result.empty():
		# there is some object between you and the player
		# maybe this is not the time to go full on sprinting
		transition_to(State.IDLE)
		return 

	# warn the player by showing '!' (TODO prettier)
	$StateLabel.text = '!'
	# TODO maybe even play a slight sound
	
	# now we know there is direct line of sight and the player is close
	# execute the actual sprinting movement
	# since we know there is clear line of sight there won't be collisions
	# no reason to use Godot physics to simulate this movement
	# instead use a tween to interpolate this movement for now
	# prepare the tween for later 
	# TODO randomize 0.8 - 1.2 player position
	var target_point = $Line2D.points[1] + position
	var duration = distance_to_player / SPRINT_VELOCITY
	$SprintSkill/SprintMovementTween.reset_all()
	$SprintSkill/SprintMovementTween.interpolate_property(self, "position", position, target_point, duration,
	Tween.TRANS_EXPO, Tween.EASE_IN_OUT)

	# TODO add grey "dusty" particles
	# TODO maybe add sprite movement perpendicularily to the movement direction in the tween
	
	# add timer, once this timer has finished, start the Tween movement
	$SprintSkill/SprintDelayTimer.start(SPRINT_DELAY)

func state_sprint(delta):
	if first_time_entering:
		begin_sprinting(delta)
	else:
		if not $SprintDelayTimer.is_stopped():  # currently waiting to sprint
			yield($SprintDelayTimer, "timeout")
			# sprint delay is over, start actually moving
			$SprintMovementTween.start()
		elif $SprintMovementTween.is_active():  # currently sprinting
			# if already sprinting, wait for the movement to complete
			yield($SprintMovementTween, "tween_all_completed")
			# then go back to being idle
			transition_to(State.IDLE)
		else:
			# if not sprinting and having been here before, go back to being idle
			# this branch should actually not be entered, it's just to make sure
			transition_to(State.IDLE)
		
