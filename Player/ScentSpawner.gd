extends Node2D

export var active := true

# scent trail
const ScentScene = preload("res://Player/Scent.tscn")

var scent_trail := []

func _on_Timer_timeout() -> void:
	if !active:
		return
	var scent := ScentScene.instance() as Scent
	scent.position = get_parent().position
	GameStatus.CURRENT_YSORT.add_child(scent)
	scent_trail.push_front(scent)
