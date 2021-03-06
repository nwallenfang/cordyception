extends PhysicsMover
class_name Phoridae

export var fly_speed := 600.0
export var walk_speed := 400.0
export var fly_sound_radius := 550.0

onready var levitation_player := $LevitationPlayer as AnimationPlayer
onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var healthbar := $Body/Healthbar
onready var projectile_spawner := $PhoridaeProjectileSpawner as PhoridaeProjectileSpawner
onready var body := $Body as Node2D
onready var stats := $PhoridaeStats
onready var line2D := $Body/Line2D as Line2D


signal follow_completed

var aggressive := false
export var very_aggressive := false
var flying := false

func _ready():
	stats.set_max_health(stats.MAX_HEALTH)
	$Body/Healthbar.visible = true

func set_hurtbox_enabled(e: bool):
	$Hurtbox.set_deferred("monitorable", e)
	$Hurtbox.set_deferred("monitoring", e)


func trigger():
	if very_aggressive:
		aggressive = true
	$StateMachine.update_transition_chances()
	$StateMachine.transition_deferred("Idle")
	$StateMachine.start()

var was_enabled_previously = false
func follow_path(target_position: Vector2):
	was_enabled_previously = $StateMachine.enabled
	$StateMachine/FollowPath.target_position = target_position
	# DON'T transition_deferred here because the sm isn't enabled yet
	# else the deferred transition just gets overwritten and the sm runs normally
	
	$StateMachine.transition_to("FollowPath")
	$StateMachine.enabled = true
	
	yield($StateMachine/FollowPath, "movement_completed")
	if not was_enabled_previously:
		$StateMachine.enabled = false
		
	emit_signal("follow_completed")

func follow_path_array(positions: Array):
	was_enabled_previously = $StateMachine.enabled
	for position in positions:
		$StateMachine.transition_to("FollowPath")
		$StateMachine/FollowPath.target_position = position
		$StateMachine.enabled = true
		yield($StateMachine/FollowPath, "movement_completed")
	emit_signal("follow_completed")
	
func follow_path_array_then_fight(positions: Array):
	was_enabled_previously = $StateMachine.enabled
	flying = true
	for position in positions:
		$StateMachine.transition_to("FollowPath")
		$StateMachine/FollowPath.target_position = position
		$StateMachine/FollowPath.stop_when_player_near = true
		$StateMachine.enabled = true
		yield($StateMachine/FollowPath, "movement_completed")
	emit_signal("follow_completed")
	
	trigger()

const FLY_DUST = preload("res://Enemies/Phoridae/FlyDust.tscn")
func create_fly_dust() -> void:
	var dust = FLY_DUST.instance()
	GameStatus.CURRENT_YSORT.add_child(dust)
	dust.global_position = global_position + Vector2(0, -5)
	dust.connect("animation_finished", dust, "queue_free")
	dust.playing = true

func set_facing_direction(direction: Vector2) -> void:
	$Body/Sprite.flip_h = direction.x < 0


func play_fly_sound_if_suitable():
	# suitable meaning you're close etc.
	if flying and not $FlySound.playing and not levitation_player.is_playing():
		# flying and not just levitating and distance
		$FlySound.play()

func _process(delta: float) -> void:
	line2D.points[1] = $ScentRay.get_player_scent_position() - position

	$StateMachine.process(delta)
	accelerate_and_move(delta)


func _on_Detection_body_entered(_body: Node) -> void:
	aggressive = true

func _on_Vision_body_exited(_body):
	if very_aggressive:
		return
	aggressive = false

var first_time_entering = true
func _on_PhoridaeStats_health_zero():
	healthbar.visible = false
	$StateLabel.visible = false
	$StateMachine.stop()
	$Body/Hitbox.set_deferred("monitoring", false)
	$Body/Hitbox.set_deferred("monitorable", false)
	$Body/Hurtbox.set_deferred("monitoring", false)
	$Body/Hurtbox.set_deferred("monitorable", false)
	# animation here
	$DeathPlayer.play("dying")
	if first_time_entering:
		GameEvents.trigger_event("enemy_died")
		first_time_entering = false


func handle_damage(attack, should_play_hit):
	$PhoridaeStats.health -= attack.damage
	add_acceleration(attack.knockback_vector())
	if should_play_hit:
		$InvincibilityPlayer.play("hit")

func _on_Hurtbox_area_entered(area):
	var parent = area.get_parent()
	var should_play_hit = not ($InvincibilityPlayer.is_playing() 
						  and $InvincibilityPlayer.current_animation == "hit")

	# parent should either be a projectile, poison mist or another weapon
	if parent is Projectile:
		handle_damage(parent as Projectile, should_play_hit)
	if parent is PoisonFragment:
		handle_damage(parent as PoisonFragment, should_play_hit)
