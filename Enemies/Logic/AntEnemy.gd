extends PhysicsMover

class_name AntEnemy


export var SELF_SOFT_COLLISION_STRENGTH := 7000.0
onready var State: Dictionary


func _ready():
	$Healthbar.MAX_HEALTH = $EnemyStats.MAX_HEALTH
	State = $StateMachine.State


func get_state() -> String:
	# return current state name
	return $StateMachine.state.name


func _on_Hurtbox_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	# parent should either be a projectile, poison mist or another weapon
	if parent is Projectile:
		var attack := parent as Projectile
		$EnemyStats.health -= attack.damage
		if get_state() != "Sprint":
			add_acceleration(attack.knockback_vector())
	if parent is PlayerCloseCombat:
		var attack := parent as PlayerCloseCombat
		$EnemyStats.health -= attack.damage
		if get_state() != "Sprint":
			add_acceleration(attack.knockback_vector())
	if parent is PoisonFragment:
		var attack := parent as PoisonFragment
		$EnemyStats.health -= attack.damage
		if get_state() != "Sprint":
			add_acceleration(attack.knockback_vector())


func _on_EnemyStats_health_changed() -> void:
	$Healthbar.health = $EnemyStats.health


func _on_EnemyStats_health_zero() -> void:
	print("sup")
	$Healthbar.visible = false
	$StateLabel.visible = false
	$StateMachine.stop()
	$Hitbox.set_deferred("monitoring", false)
	$Hitbox.set_deferred("monitorable", false)
	$Hurtbox.set_deferred("monitoring", false)
	$Hurtbox.set_deferred("monitorable", false)
	$AnimationPlayer.play("dying")  # queue_free is called at the end of this


func _physics_process(delta: float) -> void:
	$Line2D.points[1] = $ScentRay.get_player_scent_position() - position
	
	$StateMachine.process(delta)
		
	# call for handling knockback
	accelerate_and_move(delta)

func _on_Hitbox_area_entered(area: Area2D) -> void:
	# TODO disconnect this
	pass

func _on_SoftCollision_area_entered(area: Area2D) -> void:
	# they collide with themself on the first frame I think
	var parent = area.get_parent() as AntEnemy
	
	if self.get_state() != "Sprint" and parent.get_state() != "Sprint":
		var push_dir = (parent.global_position - self.global_position).normalized()
		self.add_acceleration(-SELF_SOFT_COLLISION_STRENGTH * push_dir)
		parent.add_acceleration(SELF_SOFT_COLLISION_STRENGTH * push_dir)
	
	
