extends PhysicsMover
class_name AntEnemy


export var SELF_SOFT_COLLISION_STRENGTH := 7000.0
onready var State: Dictionary

onready var anchor := $Anchor as Node2D

onready var animation_state := $AnimationTree.get("parameters/playback") as AnimationNodeStateMachinePlayback
onready var animation_tree := $AnimationTree as AnimationTree

var initial_position: Vector2

signal follow_completed

func _ready():
	initial_position = global_position
	$Healthbar.MAX_HEALTH = $EnemyStats.MAX_HEALTH
	State = $StateMachine.State
	$StateMachine.stop()
	
func reset():
	$EnemyStats.health = $EnemyStats.MAX_HEALTH
	global_position = initial_position
	_ready()
	
func trigger():
	$StateMachine.start()

func set_behavior(probabilities: Dictionary):
	# first set probability property in child state
	var state: AbstractState
	for state_name in probabilities.keys():
		state = $StateMachine.get_node(state_name)
		if state != null:
			state.RELATIVE_TRANSITION_CHANCE = probabilities[state_name]
		else:
			print("behavior WARN: state ", state_name, " doesn't exist!")

	# second force transition chance recalculation
	$StateMachine.idle_transition_chance = $StateMachine.build_absolute_transition_chances()
	$StateMachine.find_initial_state_and_prev()

func get_state() -> String:
	# return current state name
	return $StateMachine.state.name

var was_enabled_previously = false
func _on_FollowPath_movement_completed() -> void:
	# disable state machine when done with moving
	# if it was disabled before
	if not was_enabled_previously:
		$StateMachine.enabled = false
		
	emit_signal("follow_completed")
		
		
func shoot_single_projectile(target_position: Vector2):
	was_enabled_previously = $StateMachine.enabled
	$StateMachine/SimpleShoot.start_shooting_single_projectile(target_position)


func follow_path(target_position: Vector2):
	was_enabled_previously = $StateMachine.enabled
	$StateMachine/FollowPath.target_position = target_position
	$StateMachine.transition_to("FollowPath")
	$StateMachine.enabled = true
	

func set_facing_direction(direction: Vector2):
	# im animation tree setzen.
	$AnimationTree.set("parameters/Idle/blend_position", direction)

func handle_damage(attack, should_play_hit):
	$EnemyStats.health -= attack.damage
	if get_state() != "Sprint":
		add_acceleration(attack.knockback_vector())
	if should_play_hit:
		$InvincibilityPlayer.play("hit")
		
func _on_Hurtbox_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	var should_play_hit = not ($InvincibilityPlayer.is_playing() 
						  and $InvincibilityPlayer.current_animation == "hit")

	
	# parent should either be a projectile, poison mist or another weapon
	if parent is Projectile:
		handle_damage(parent as Projectile, should_play_hit)
	if parent is PlayerCloseCombat:
		handle_damage(parent as PlayerCloseCombat, should_play_hit)
	if parent is PoisonFragment:
		handle_damage(parent as PoisonFragment, should_play_hit)


func _on_EnemyStats_health_changed() -> void:
	$Healthbar.health = $EnemyStats.health


func _on_EnemyStats_health_zero() -> void:
	$Healthbar.visible = false
	$StateLabel.visible = false
	$StateMachine.stop()
	$Hitbox.set_deferred("monitoring", false)
	$Hitbox.set_deferred("monitorable", false)
	$Hurtbox.set_deferred("monitoring", false)
	$Hurtbox.set_deferred("monitorable", false)
	
	var last_state: String = animation_state.get_current_node()
	# set idle blend position as last movement blend position
	var last_blend = animation_tree.get("parameters/"+ last_state + "/blend_position")
	animation_tree.set("parameters/Idle/blend_position", last_blend)
	animation_state.travel("Idle")
	$AnimationPlayer.play("dying")  # queue_free is called at the end of this
	
	GameEvents.trigger_event("enemy_died")


func _physics_process(delta: float) -> void:
	$Line2D.points[1] = $ScentRay.get_player_scent_position() - position
	
	$StateMachine.process(delta)
		
	# call for handling knockback
	accelerate_and_move(delta)

func _on_SoftCollision_area_entered(area: Area2D) -> void:
	var parent = area.get_parent() as AntEnemy
	
	if self.get_state() != "Sprint" and parent.get_state() != "Sprint":
		var push_dir = (parent.global_position - self.global_position).normalized()
		self.add_acceleration(-SELF_SOFT_COLLISION_STRENGTH * push_dir)
		parent.add_acceleration(SELF_SOFT_COLLISION_STRENGTH * push_dir)
