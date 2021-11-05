extends Node2D

# probs gonna stay at 1 since enemy will always deal same dmg to player
export var PROJECTILE_DAMAGE := 1
const EnemyProjectile := preload("res://Projectiles/EnemyProjectile.tscn")

export var SPAWN_TIME_MIN := 3
export var SPAWN_TIME_MAX := 6

var volley_index: int = 0

func _ready() -> void:
	randomize()
	$DebugSpawnTimer.wait_time = rand_range(SPAWN_TIME_MIN, SPAWN_TIME_MAX)
	$DebugSpawnTimer.start()

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
	if randi() % 2 == 1:
		spawn_radial_projectiles(16)
	else:
		# TODO dirty code, only works if parent has Sprite node!
		var direction: float = self.get_parent().get_node("Sprite").rotation
		spawn_cone_projectile_volley(direction, 30, 5, 0.2, 3)
		
	$DebugSpawnTimer.wait_time = rand_range(SPAWN_TIME_MIN, SPAWN_TIME_MAX)


func spawn_single_spread(base_direction:float, spread_in_degree:int, amount: int):
	# helper method
	# start with base direction turned half the spread 
	var start_direction = base_direction - deg2rad(spread_in_degree) / 2
	var step = deg2rad(spread_in_degree)/amount
	
	for i in range(amount):
		create_projectile(start_direction + i * step)


func spawn_cone_projectile_volley(base_direction:float, spread_in_degree:int, amount: int, time_delta:float, how_often:int):
	# amount: how many projectiles per spread
	# spread_in_degree: range of the projectiles per spread (say 45 degrees) half up/down
	# base_direction: direction of center of spread
	# time_delta: time between volley shots
	# how_often: amount of volley shots
	
	$VolleyTimer.wait_time = time_delta
	$VolleyTimer.start()
	
	for i in range(how_often):
		spawn_single_spread(base_direction, spread_in_degree, amount)
		yield($VolleyTimer, "timeout")

	$VolleyTimer.stop()
	 

func spawn_radial_projectiles(amount: int) -> void:
	var degree_step = 2*PI/amount	
	var direction: float
	
	for i in range(amount):
		create_projectile(i * degree_step)
