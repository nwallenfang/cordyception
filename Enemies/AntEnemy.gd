extends SlideMover


enum State {
	CHASE_PLAYER, IDLE, SPRINT, SHOOT_STUFF
}

const idle_transition_chance = {
	State.IDLE: 0.5,
	State.CHASE_PLAYER: 0.3,
	State.SHOOT_STUFF: 0.1,
	State.SPRINT: 0.1
}

var state = State.IDLE


func _ready() -> void:
	if OS.is_debug_build():
		$StateLabel.visible = true
		$Line2D.visible = true


func _on_Hurtbox_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	# parent should either be a projectile, poison mist or another weapon
	if parent is Projectile:
		var projectile := parent as Projectile
		$EnemyStats.health -= projectile.damage
		add_velocity(projectile.knockback_vector())


func _on_EnemyStats_health_changed() -> void:
	$Healthbar.health = $EnemyStats.health


func _on_EnemyStats_health_zero() -> void:
	queue_free()

func match_state():
	$StateLabel.text = State.keys()[state]
	match state:
		State.IDLE:
			state_idle()
		State.SPRINT:
			state_sprinting()
		State.CHASE_PLAYER:
			state_chasing_player()
		State.SHOOT_STUFF:
			state_shooting_stuff()
	
func state_sprinting():
	pass
	
func state_chasing_player():
	pass
	
func state_shooting_stuff():
	pass
	
func transition_to_new_state(new_state):
	if new_state == State.IDLE:
		state = State.IDLE
		$StateTimers/Idle.start(0.5)
	else:
		state = new_state
	
func state_idle():
	# wait for a while first
	# see if we're already idle for longer than minimum
	if not $StateTimers/Idle.is_stopped():
		# still running, pass
		return
	
	# another day of being an idle enemy ant
	# who knows what the day may bring
	# maybe shoot some stuff
	# maybe even go for a little walk
	# let the dice decide
	var rand := randf()  # random seed
	var psum: float = 0.0 # sum of probabilities that were already checked in for loop
	
	# idea: if the random number between 0 and 1 is smaller than the 
	# states up to some point, enter the state
	# else go on. For this the state probabilities' sum has to be 1
	for new_state in State.values():
		psum += idle_transition_chance[new_state]
		if rand <= psum:
			transition_to_new_state(new_state)
			break
		# random seed doesn't fit new state, go next
		

func _physics_process(delta: float) -> void:
	# call for handling knockback
	accelerate_and_move(delta)
	$Line2D.points[1] = $ScentRay.get_player_scent_position() - position
	
	match_state()
