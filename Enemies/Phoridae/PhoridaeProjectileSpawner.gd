extends Node2D
class_name PhoridaeProjectileSpawner

const PROJECTILE = preload("res://Enemies/Phoridae/PhoridaeProjectile.tscn")

func spawn_projectile() -> void:
	var projectile := PROJECTILE.instance() as PhoridaeProjectile
	GameStatus.CURRENT_YSORT.add_child(projectile)
	projectile.global_position = global_position
	projectile.start()
