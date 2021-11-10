extends PhysicsMover

class_name AntEnemy

enum State {
	IDLE, CHASE_PLAYER, SHOOT_STUFF, SPRINT, 
}

export var IDLE_TIME := 0.2
export var SELF_SOFT_COLLISION_STRENGTH := 7000.0

# distance where it's still prob. 0 of stopping the chase
# basically, the probability of stopping the chase increases by increasing this distance
const CHASE_BASE_DISTANCE := 150.0

# should be same order as State Enum! 
var idle_transition_chance = {
	State.IDLE: 0.0,
	State.CHASE_PLAYER: 0.44,
	State.SHOOT_STUFF: 0.26,
	State.SPRINT: 0.33
}

# will be true for the first frame you are in a new state
var first_time_entering = true
var previous_non_idle_state = State.SPRINT
var state = State.IDLE
var state_machine_enabled := false

func _ready() -> void:
	if GameStatus.AUTO_ENEMY_BEHAVIOR:
		state_machine_enabled = true
	(self.STOP_CHASE_DENSITY as Curve).max_value = CHASE_BASE_DISTANCE
	if OS.is_debug_build():
#		$StateLabel.visible = true
#		$Line2D.visible = true
		pass


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
export var SPRINT_DELAY := 0.4
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

	# warn the player by showing '!'
	$SprintWarning.show()
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
			$SprintWarning.hide()
		elif $SprintMovementTween.is_active():  # currently sprinting
			# if already sprinting, wait for the movement to complete
			$AnimationPlayer.play("sprinting")
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
		
	# shooting stuff could be depending on distance to player..
	# if too far from the player, don't shoot at all but enter another state instead
	
func transition_to(new_state):
#	print("transition from ", State.keys()[state], " to ", State.keys()[new_state])
	$StateLabel.text = State.keys()[new_state]
	first_time_entering = true
	if state != State.IDLE:
		previous_non_idle_state = state
	state = new_state
	
func transition_to_random_state():
	transition_to(get_random_next_state(idle_transition_chance))

func get_random_next_state(transition_chances: Dictionary):
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
		psum += transition_chances[new_state]
		if rand <= psum:
			return new_state
		# random seed doesn't fit new state, go next
	
	print("ERROR no random state was drawn with ", transition_chances)
	
func transition_to_random_different_state():
	# transition to a new state different from last non-idle state
	# copy idle transition chances
	var state_transition_chances = self.idle_transition_chance.duplicate()
	var prob_to_remove: float = state_transition_chances[previous_non_idle_state]
	var number_possible_states = 2  # could be calculated to generalize better
	
	state_transition_chances[self.previous_non_idle_state] = 0.0
	
	# convention that Idle is at number 1 in the keys
	for i in range(1, 4):
		if i != self.previous_non_idle_state:
			state_transition_chances[i] += prob_to_remove / number_possible_states
			
	transition_to(get_random_next_state(state_transition_chances))
	
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
	transition_to_random_different_state()
	$IdleTimer.stop()


func _on_Hitbox_area_entered(area: Area2D) -> void:
	# push itself slightly if a body enters the enemy ant's body hitbox
	pass
	# PLAYER KNOCKBACK ON CONTACT INSTEAD
#	var parent = area.get_parent()
#	if parent is Player:
#		var player = parent as Player
#		var push_dir = -(player.global_position - self.global_position).normalized()
#		# or rather: did not JUST turn invincible but was also invincible before this
#		var invincTimer: Timer = player.get_node("Hurtbox/InvincibilityTimer")
#		var is_invincible = invincTimer.time_left < 0.9 * invincTimer.wait_time
#
#		if self.state != State.SPRINT and not is_invincible :
#			self.add_acceleration(SOFT_COLLISION_ACC * push_dir)
#	if parent is AntEnemy:
#		print("?!?")


func _on_SoftCollision_area_entered(area: Area2D) -> void:
	# they collide with themself on the first frame I think
	var parent = area.get_parent()
	print(parent)  # should be AntEnemy, can't check because of Godot
	
	var push_dir = (parent.global_position - self.global_position).normalized()
	self.add_acceleration(-SELF_SOFT_COLLISION_STRENGTH * push_dir)
	parent.add_acceleration(SELF_SOFT_COLLISION_STRENGTH * push_dir)
	
	
