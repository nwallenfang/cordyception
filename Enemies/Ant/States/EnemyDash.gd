extends Node2D
class_name EnemyDash

signal add_dash_frame


func start_dash_effects() -> void:
	$DashParticles.emitting = true
	$DashFrameTimer.start(0.1)
	$DashCooldown.start()

func stop_dash_effects() -> void:
	$DashParticles.emitting = false
	$DashFrameTimer.stop()


func _on_DashFrameTimer_timeout() -> void:
	emit_signal("add_dash_frame")
