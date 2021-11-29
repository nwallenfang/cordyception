extends Node2D
class_name StagBeetle

onready var origin := $Origin as Node2D
onready var projectile_origin := $Origin/ProjectileOrigin as Node2D
onready var swipe_hitbox := $Origin/SwipeHitbox as Area2D
onready var swipe_projectile := $SwipeProjectile as Node2D
onready var melee_hitbox := $Origin/MeleeHitbox as Area2D

onready var sprite := $Origin/AnimatedSprite as AnimatedSprite
onready var state_machine := $StateMachine as StagStateMachine

var sprite_rotation := 0.0 setget set_rotation

export var MAX_HEALTH := 140 setget set_max_health
onready var health := MAX_HEALTH setget set_health
export var DAMAGE := 1

signal boss_health_zero
signal boss_health_changed


func _ready():
	for anim in sprite.frames.get_animation_names():
		play_animation(anim)
	play_animation("idle")
	connect("boss_health_changed", self, "boss_health_changed")
	connect("boss_health_zero", self, "boss_health_zero")
	


func _process(delta):
	$StateMachine.process(delta)

func boss_health_changed():

	GameStatus.CURRENT_UI.boss_healthbar.health = health
	
	
func boss_health_zero():
	$SpeechBubble.set_text("ARRRGHGHHGH!! I'M DEAD.")

func set_health(new_health: int) -> void:
	var health_prev = health
	health = max(new_health, 0)

	GameStatus.CURRENT_UI.boss_healthbar.health = health

	if health <= 0:
		emit_signal("boss_health_zero")
	

func set_max_health(new_max: int):
	MAX_HEALTH = new_max
	#set_health(min(MAX_HEALTH, health))
	set_health(MAX_HEALTH)
	GameStatus.CURRENT_UI.boss_healthbar.MAX_HEALTH = MAX_HEALTH


func set_rotation(rot):
	rot = normalize_angle(rot)
	origin.rotation = deg2rad(rot)
	sprite_rotation = rot

func play_animation(animation_name: String, start_at_zero: bool = true) -> void:
	sprite.play(animation_name)
	if start_at_zero:
		sprite.frame = 0

func get_animation_length(animation_name: String) -> float:
	var frames := sprite.frames
	var frame_count := frames.get_frame_count(animation_name)
	var animation_speed:= frames.get_animation_speed(animation_name)
	return float(frame_count) / animation_speed

func normalize_angle(degs: float) -> float:
	degs = rad2deg(deg2rad(degs))
	if degs > 180:
		degs -= 360
	elif degs < -180:
		degs += 360
	return degs


func handle_damage(attack, should_play_hit):
	self.health -= attack.damage
	# no knockback lol
	# TODO !!!
#	if should_play_hit:
#		$InvincibilityPlayer.play("hit")

func _on_Hurtbox_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
#	var should_play_hit = not ($InvincibilityPlayer.is_playing() 
#						  and $InvincibilityPlayer.current_animation == "hit")
	var should_play_hit = true
	
	# parent should either be a projectile, poison mist or another weapon
	if parent is Projectile:
		handle_damage(parent as Projectile, should_play_hit)
	if parent is PlayerCloseCombat:
		handle_damage(parent as PlayerCloseCombat, should_play_hit)
	if parent is PoisonFragment:
		handle_damage(parent as PoisonFragment, should_play_hit)


func _on_EnemyStats_health_changed() -> void:
	$Healthbar.health = $EnemyStats.health
