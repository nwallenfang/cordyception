extends PhysicsMover


enum State {
	CHASE_PLAYER, IDLE, SPRINT, SHOOT_STUFF
}

export var IDLE_TIME := 0.2

# distance where it's still prob. 0 of stopping the chase
# basically, the probability of stopping the chase increases by increasing this distance
const CHASE_BASE_DISTANCE := 150.0

var idle_transition_chance = {
	State.IDLE: 0.0,
	State.CHASE_PLAYER: 0.33,
	State.SHOOT_STUFF: 0.33,
	State.SPRINT: 0.34
}

# will be true for the first frame you are in a new state
var first_time_entering = true
var previous_non_idle_state
var state = State.IDLE
var state_machine_enabled := true

func _ready() -> void:
	(self.STOP_CHASE_DENSITY as Curve).max_value = CHASE_BASE_DISTANCE
	if not GameStatus.ENEMY_BEHAVIOR:
		state_machine_enabled = false
	if OS.is_debug_build():
		$StateLabel.visible = true
		$Line2D.visible = true


func _on_Hurtbox_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	# parent should either be a projectile, poison mist or another weapon
	if parent is Projectile:
		var attack := parent as Projectile
		$EnemyStats.health -= attack.damage
		if state != State.SPRINT:
			add_acceleration(attack.knockback_vector())
	if parent is PlayerCloseCombat:
		var attack := parent as PlayerCloseCombat
		$EnemyStats.health -= attack.damage
		if state != State.SPRINT:
			add_acceleration(attack.knockback_vector())
	if parent is PoisonFragment:
		var attack := parent as PoisonFragment
		$EnemyStats.health -= attack.damage


func _on_EnemyStats_health_changed() -> void:
	$Healthbar.health = $EnemyStats.health


func _on_EnemyStats_health_zero() -> void:
	# TODO I would like not to kick around dead bodies quite as hard..
	# TODO
	$Healthbar.visible = false
	$StateLabel.visible = false
	state_machine_enabled = false
	# stop Tween movement if currently sprinting
	$SprintMovementTween.stop_all()
	
	$AnimationPlayer.play("dying")  # queue_free is called at the end of this

func match_state(delta):
	var this_was_the_first_time = first_time_entering
	match state:
		State.IDLE:
			state_idle()
		State.SPRINT:
			state_sprint(delta)
		State.CHASE_PLAYER:
			state_chase_player()
		State.SHOOT_STUFF:
			state_shoot_stuff()
	
	if this_was_the_first_time:
		first_time_entering = false

# variables local to state sprint, if another enemy needs this skill
# you could take these variables and the method to a new script SprintAttack
const MAX_SPRINT_DISTANCE := 400
export var SPRINT_VELOCITY := 90 # px/s (Tween property)
export var SPRINT_DELAY := 0.3

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
#	var target_point = $Line2D.points[1] + position
	var target_point = position + MAX_SPRINT_DISTANCE * Vector2.UP.rotated(direction)
	# duration should be independent from distance_to_player
	var duration = 0.68
	
	# TODO polish this
	$SprintMovementTween.reset_all()
	$SprintMovementTween.interpolate_property(self, "position", position, target_point, duration,
	Tween.TRANS_LINEAR)

	# TODO add grey "dusty" particles
	# TODO maybe add sprite movement perpendicularily to the movement direction in the tween
	
	# add timer, once this timer has finished, start the Tween movement
	$SprintDelayTimer.start(SPRINT_DELAY)

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


# randomly decide (depending on distance to player) whether it is time to
# stop chasing

export(Curve) var STOP_CHASE_DENSITY # probability density curve
func should_stop_chasing(distance: float) -> bool:
	# cap distance from 0 to CHASE_BASE_DISTANCE
	var distance_normalized = min(distance, CHASE_BASE_DISTANCE)
	var stop_chase_probability = max(STOP_CHASE_DENSITY.interpolate_baked(CHASE_BASE_DISTANCE - distance_normalized), 0)
	var random_decider = randf()
	return random_decider < stop_chase_probability

export var CHASE_ACCELERATION := 2200.0
var starting_point: Vector2
var full_length: float
var progress: float
func state_chase_player():
	var distance_vector := ($Line2D.points[1] - $Line2D.points[0]) as Vector2
	var direction_vector = distance_vector.normalized()
	var distance_to_player_scent = distance_vector.length()
	
	if should_stop_chasing(distance_to_player_scent):
		transition_to(State.IDLE)
	
	add_acceleration(CHASE_ACCELERATION * direction_vector)	
	
export var SHOOT_DELAY := 0.2
func state_shoot_stuff():

	# for now either shoot a cone in the player direction or shoot radial
	if first_time_entering:
		var direction = $Line2D.points[1].angle() + PI/2
		var random_flip := randi() % 2
		if random_flip:
			$EnemyProjectileSpawner.spawn_cone_projectile_volley(direction, 30, 5, 0.2, 3)
		else:
			$EnemyProjectileSpawner.spawn_radial_projectiles(16)
			
		$ShootDelayTimer.start()
	else:
		# wait for shoot delay
		yield($ShootDelayTimer, "timeout")
		# go back to being idle in the next frame
		transition_to(State.IDLE)		
		
	# TODO shooting stuff should be depending on distance to player
	# if too far from the player, don't shoot at all but enter another state instead
	

	


	
func transition_to(new_state):
#	print("transition from ", State.keys()[state], " to ", State.keys()[new_state])
	$StateLabel.text = State.keys()[new_state]
#	if new_state == State.IDLE:
#		$IdleTimer.start(IDLE_TIME)
	first_time_entering = true
	state = new_state
	
func transition_to_random_state():
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
			transition_to(new_state)
			break
		# random seed doesn't fit new state, go next
		
	
	
func state_idle():
	if $IdleTimer.is_stopped():
		$IdleTimer.start(IDLE_TIME)
	pass
	

func _physics_process(delta: float) -> void:
	$Line2D.points[1] = $ScentRay.get_player_scent_position() - position
	
	if state_machine_enabled:
		match_state(delta)
		
	# call for handling knockback
	accelerate_and_move(delta)


func _on_IdleTimer_timeout() -> void:
	transition_to_random_state()
	$IdleTimer.stop()
