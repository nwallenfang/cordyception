extends Projectile

func _ready() -> void:
	$AnimationPlayer.play("active")
	$FadeOutTimer.start()


func _on_FadeOutTimer_timeout() -> void:
	$Hitbox.set_deferred("monitoring", false)
	$Hitbox.set_deferred("monitorable", false)
	$FadeOut.interpolate_property(self, "modulate", Color.white, Color.transparent, 0.5, Tween.TRANS_CIRC)
	$FadeOut.start()



func _on_FadeOut_tween_all_completed() -> void:
	call_deferred("queue_free")
