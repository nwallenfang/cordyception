extends Node2D

# probs gonna stay at 1 since enemy will always deal same dmg to player
export var PROJECTILE_DAMAGE := 1
const EnemyProjectile := preload("res://Projectiles/EnemyProjectile.tscn")

func create_projectile(direction: float) -> void:	
	# create projectile
	var projectile := EnemyProjectile.instance()
	var ysort = GameStatus.CURRENT_YSORT
	ysort.add_child(projectile)
	
	projectile.direction = Vector2.UP.rotated(direction)
	projectile.global_position = self.global_position
	projectile.damage = PROJECTILE_DAMAGE
	projectile.get_node("Sprite").rotation = direction


func _on_SpawnTimer_timeout() -> void:
	var random_direction = randf()*2*PI
	create_projectile(random_direction)
