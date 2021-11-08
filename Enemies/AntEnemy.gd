extends SlideMover


enum State {
	CHASE_PLAYER, IDLE, SPRINT, SHOOT_STUFF
}

export var IDLE_TIME := 0.5
export var SHOOT_TIME := 1.5

# these two won't be needed probably but are here for debugging purposes
export var CHASE_TIME := 1.0
export var SPRINT_TIME := 1.0

const idle_transition_chance = {
	State.IDLE: 0.5,
	State.CHASE_PLAYER: 0.2,
	State.SHOOT_STUFF: 0.2,
	State.SPRINT: 0.1
}

var state = State.IDLE
var first_time_entering := false

func _ready() -> void:
	if OS.is_debug_build():
		$StateLabel.visible = true
		#$Line2D.visible = true


func _on_Hurtbox_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	# parent should either be a projectile, poison mist or another weapon
	if parent is Projectile:
		var attack := parent as Projectile
		$EnemyStats.health -= attack.damage
		add_velocity(attack.knockback_vector())
	if parent is PlayerCloseCombat:
		var attack := parent as PlayerCloseCombat
		$EnemyStats.health -= attack.damage
		add_velocity(attack.knockback_vector())


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
			state_sprint()
		State.CHASE_PLAYER:
			state_chase_player()
		State.SHOOT_STUFF:
			state_shoot_stuff()
			

	
func state_sprint():
	if $StateTimer.is_stopped():
			transition_to_new_state(State.IDLE)
	
func state_chase_player():
	if $StateTimer.is_stopped():
			transition_to_new_state(State.IDLE)
	
func state_shoot_stuff():
	if not first_time_entering:
		if $StateTimer.is_stopped():
			transition_to_new_state(State.IDLE)
		# check timer if it's time to transition
		# still running, pass
		return

	
	# for now either shoot a cone in the player direction or shoot radial
	var direction = $Line2D.points[1].angle() + PI/2
	var random_flip := randi() % 2
	if random_flip:
		$EnemyProjectileSpawner.spawn_cone_projectile_volley(direction, 30, 5, 0.2, 3)
	else:
		$EnemyProjectileSpawner.spawn_radial_projectiles(16)
		
	first_time_entering = false

	# TODO shooting stuff should be depending on distance to player
	# if too far from the player, don't shoot at all but enter another state instead
	
func transition_to_new_state(new_state):
	first_time_entering = true
	
	match new_state:
		State.IDLE:
			$StateTimer.start(IDLE_TIME)
		State.SHOOT_STUFF:
			$StateTimer.start(SHOOT_TIME)
		State.SPRINT:
			$StateTimer.start(SPRINT_TIME)
		State.CHASE_PLAYER:
			$StateTimer.start(CHASE_TIME)
			
	state = new_state
	
func state_idle():
	# wait for a while first
	# see if we're already idle for longer than minimum
	if not $StateTimer.is_stopped():
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
