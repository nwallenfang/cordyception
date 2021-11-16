extends Node2D
class_name Thorn

export var knock_back := 100000

onready var area := $Area2D as Area2D
onready var polygon := $Area2D/CollisionShape2D.polygon as PoolVector2Array

func get_nearest_point(pos: Vector2) -> Vector2:
	var best := polygon[0] as Vector2
	var shortest_distance := pos.distance_to(best)
	for v in polygon:
		v += global_position
		if pos.distance_to(v) < shortest_distance:
			best = v
			shortest_distance = pos.distance_to(v)
	return best

func knockback_vector() -> Vector2:
	var player = GameStatus.CURRENT_PLAYER
	var nearest := get_nearest_point(player.global_position)
	return knock_back * nearest.direction_to(player.global_position)
	
