extends Node2D
class_name RedAphid

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
