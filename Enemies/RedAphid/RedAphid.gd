extends PhysicsMover
class_name RedAphid

onready var scentray := $ScentRay as ScentRay

export var move_speed := 50000.0
export(NodePath) var mother_path : NodePath setget set_mother_path
export var mother_radius := 100.0
var mother: Node2D = null

var ready_to_throw := true
var throw_origin : Node2D = null
signal ready_to_launch

export var is_full_attacker := false
export var is_boss_aphid := false

func set_mother_path(path: NodePath):
	if path != "":
		mother_path = path
		if has_node(mother_path):
			mother = get_node(mother_path)

func _ready() -> void:
	$BarScaler/Healthbar.MAX_HEALTH = $EnemyStats.MAX_HEALTH
	$StateMachine.enabled = false
	set_mother_path(mother_path)
	set_ignite_area(false)
	set_roll_area(false)

	

func set_ignite_area(b: bool):
	$IgniteArea.monitorable = b
	$IgniteArea.monitoring = b

func set_roll_area(b: bool):
	$RollCollision.monitorable = b
	$RollCollision.monitoring = b

const SPEED_DUST = preload("res://Enemies/RedAphid/SpeedDust.tscn")
func create_speed_dust(direction: Vector2):
	var dust = SPEED_DUST.instance()
	GameStatus.CURRENT_YSORT.add_child(dust)
	dust.global_position = global_position
	dust.get_node("AnimatedSprite").connect("animation_finished", dust, "queue_free")
	dust.scale.x *= -1 if direction.x > 0 else 1
	dust.rotation = -direction.angle_to(Vector2.RIGHT) if direction.x > 0 else -direction.angle_to(Vector2.LEFT)
	dust.get_node("AnimatedSprite").frame = 0
	dust.get_node("AnimatedSprite").playing = true

const IMPACT_DUST = preload("res://Enemies/RedAphid/ImpactDust.tscn")
func create_impact_dust():
	var dust = IMPACT_DUST.instance()
	GameStatus.CURRENT_YSORT.add_child(dust)
	dust.global_position = global_position
	dust.get_node("AnimatedSprite").connect("animation_finished", dust, "queue_free")
	dust.get_node("AnimatedSprite").frame = 0
	dust.get_node("AnimatedSprite").playing = true

const EXPLOSION = preload("res://Enemies/RedAphid/Explosion.tscn")
func create_explosion_and_die():
	var explosion = EXPLOSION.instance()
	GameStatus.CURRENT_YSORT.add_child(explosion)
	explosion.global_position = global_position
	GameEvents.trigger_event("enemy_died")
	queue_free()

var facing_right := true

func set_facing_direction(direction: Vector2):
	if direction == Vector2.ZERO:
		return
	facing_right = direction.x >= 0

func play_walk_animation(direction: Vector2):
	set_facing_direction(direction)
	if direction == Vector2.ZERO:
		$AnimationPlayer.play("idle_right" if facing_right else "idle_left")
	else:
		$AnimationPlayer.play("walk_right" if facing_right else "walk_left")

func play_ignite():
	$AnimationPlayer.play("idle_right" if facing_right else "idle_left")
	$ExplosionPlayer.play("ignite")

func _process(delta: float) -> void:
	#line2D.points[1] = $ScentRay.get_player_scent_position() - global_position
	$StateMachine.process(delta)
	do_soft_collision(delta)
	accelerate_and_move(delta)

func play_start_roll():
	$SpinPlayer.play("spin_right" if facing_right else "spin_left")
	$AnimationPlayer.play("roll_in_right" if facing_right else "roll_in_left")

func play_speed_roll(direction: Vector2):
	create_speed_dust(direction)
	$SpinPlayer.play("spin_right_fast" if facing_right else "spin_left_fast")

signal roll_stopped
func play_stop_roll():
	$SpinPlayer.play("spin_right" if facing_right else "spin_left")
	$AnimationPlayer.play("roll_out_right" if facing_right else "roll_out_left")
	yield(get_tree().create_timer($SpinPlayer.get_animation("spin_left").length * 2), "timeout")
	$SpinPlayer.play("idle")
	emit_signal("roll_stopped")

func _on_RollCollision_body_entered(body: Node) -> void:
	create_explosion_and_die()

var ignite_ready := false
func _on_IgniteArea_body_entered(body: Node) -> void:
	ignite_ready = true

export var soft_collision_speed := 7000.0
func do_soft_collision(delta):
	for area in $SoftCollision.get_overlapping_areas():
		if area.get_parent() is get_script():
			add_acceleration(GameStatus.const_delta * soft_collision_speed * area.get_parent().global_position.direction_to(global_position))

func handle_damage(attack, should_play_hit):
	$EnemyStats.health -= attack.damage
	add_acceleration(attack.knockback_vector())
#	if should_play_hit:
#		$InvincibilityPlayer.play("hit")
		
func _on_Hurtbox_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	var should_play_hit = false
#	var should_play_hit = not ($InvincibilityPlayer.is_playing() 
#						  and $InvincibilityPlayer.current_animation == "hit")

	
	# parent should either be a projectile, poison mist or another weapon
	if parent is Projectile:
		handle_damage(parent as Projectile, should_play_hit)
	if parent is PlayerCloseCombat:
		handle_damage(parent as PlayerCloseCombat, should_play_hit)
	if parent is PoisonFragment:
		handle_damage(parent as PoisonFragment, should_play_hit)


func set_hurtbox_enabled(e: bool):
	$Hurtbox.set_deferred("monitorable", e)
	$Hurtbox.set_deferred("monitoring", e)

func _on_EnemyStats_health_changed():
	$BarScaler/Healthbar.health = $EnemyStats.health


func _on_EnemyStats_health_zero():
	set_hurtbox_enabled(false)
	$StateMachine.transition_deferred("Ignite")

