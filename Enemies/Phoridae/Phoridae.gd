extends PhysicsMover
class_name Phoridae

export var fly_speed := 600.0
export var walk_speed := 400.0

onready var levitation_player := $LevitationPlayer as AnimationPlayer
onready var animation_player := $AnimationPlayer as AnimationPlayer
onready var healthbar := $Body/Healthbar
onready var projectile_spawner := $PhoridaeProjectileSpawner as PhoridaeProjectileSpawner
onready var body := $Body as Node2D
onready var stats := $PhoridaeStats

var aggressive := false
var flying := false

func _ready():
	$StateMachine.start()
	stats.set_max_health(stats.MAX_HEALTH)
	

const FLY_DUST = preload("res://Enemies/Phoridae/FlyDust.tscn")
func create_fly_dust() -> void:
	var dust = FLY_DUST.instance()
	GameStatus.CURRENT_YSORT.add_child(dust)
	dust.global_position = global_position + Vector2(0, -5)
	dust.connect("animation_finished", dust, "queue_free")
	dust.playing = true

func set_facing_direction(direction: Vector2) -> void:
	$Body/Sprite.flip_h = direction.x < 0


func _process(delta: float) -> void:
	$Line2D.points[1] = $ScentRay.get_player_scent_position() - position
	$StateMachine.process(delta)
	accelerate_and_move(delta)


func _on_Detection_body_entered(_body: Node) -> void:
	aggressive = true

func _on_Vision_body_exited(_body):
	aggressive = false


func _on_PhoridaeStats_health_zero():
	healthbar.visible = false
	$StateLabel.visible = false
	$StateMachine.stop()
	$Body/Hitbox.set_deferred("monitoring", false)
	$Body/Hitbox.set_deferred("monitorable", false)
	$Body/Hurtbox.set_deferred("monitoring", false)
	$Body/Hurtbox.set_deferred("monitorable", false)
	# animation here
	queue_free()
	
	GameEvents.trigger_event("enemy_died")


func handle_damage(attack, should_play_hit):
	$PhoridaeStats.health -= attack.damage
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
