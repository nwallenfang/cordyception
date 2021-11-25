extends Node2D
class_name Thorn

export var knock_back := 100000
export var enrichment_level := 2

onready var area := $Area2D as Area2D
onready var polygon := $Area2D/CollisionShape2D.polygon as PoolVector2Array

func point_between(A: Vector2, B: Vector2) -> Vector2:
	return (A + B) / 2.0

func enrich_polygon(base_poly: PoolVector2Array) -> PoolVector2Array:
	var poly := PoolVector2Array([])
	for i in range(base_poly.size()):
		poly.append(point_between(base_poly[i-1], base_poly[i]))
		poly.append(base_poly[i])
	return poly

func get_nearest_point(pos: Vector2) -> Vector2:
	polygon = $Area2D/CollisionShape2D.polygon
	var best := polygon[0] as Vector2
	var shortest_distance := pos.distance_to(best)
	var poly = PoolVector2Array(polygon)
	for i in range(enrichment_level):
		poly = enrich_polygon(poly)
	for v in poly:
		v.x *= scale.x
		v.y *= scale.y
		v = v.rotated(rotation)
		v += global_position
		
		# debug scent for seeing the used points
		var scent = load("res://Player/Scent.tscn").instance()
		scent.visible = true
		GameStatus.CURRENT_YSORT.add_child(scent)
		scent.global_position = v
		scent.modulate = Color.red
		
		if pos.distance_to(v) < shortest_distance:
			best = v
			shortest_distance = pos.distance_to(v)
	return best

func knockback_vector() -> Vector2:
	var player = GameStatus.CURRENT_PLAYER
	var nearest := get_nearest_point(player.get_node("Anchor").global_position)
	var rotation = null
	return knock_back * nearest.direction_to(player.get_node("Anchor").global_position)
	
