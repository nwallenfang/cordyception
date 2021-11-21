extends Node2D
class_name RedAphid

onready var line2D := $Line2D as Line2D

const SPEED_DUST = preload("res://Enemies/RedAphid/SpeedDust.tscn")
func create_speed_dust():
	var dust = SPEED_DUST.instance()
	GameStatus.CURRENT_YSORT.add_child(dust)
	dust.global_position = global_position
	dust.connect("animation_finished", dust, "queue_free")
	dust.playing = true

const EXPLOSION = preload("res://Enemies/RedAphid/Explision.tscn")
func create_expolision():
	var explosion = SPEED_DUST.instance()
	GameStatus.CURRENT_YSORT.add_child(explosion)
	explosion.global_position = global_position

var facing_right := true
func play_walk_animation(direction: Vector2):
	if direction == Vector2.ZERO:
		$AnimationPlayer.play("idle_right" if facing_right else "idle_left")
	else:
		facing_right = direction.x >= 0
		$AnimationPlayer.play("walk_right" if facing_right else "walk_left")
