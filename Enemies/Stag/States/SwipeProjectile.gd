extends Node2D

var SPEED := 450
var direction
var velocity = Vector2.ZERO



func _physics_process(delta: float) -> void:
	self.position += delta * velocity
