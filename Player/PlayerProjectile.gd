extends Projectile

export var GREEN_LIGHT_ON := 1.8
export var GREEN_LIGHT_OFF := 1.1


func splash_sound():  # maybe :)
	# if projectile in view port (later addition TODO): or if it has hit an enemy
	var transform: Transform2D = get_canvas_transform()
	var scale: Vector2 = transform.get_scale()
	var viewport_rect := Rect2(-transform.origin / scale, get_viewport_rect().size / scale)
	
	if viewport_rect.has_point(self.global_position):
		$SplashAudio.play()

func _ready() -> void:
	$Hitbox/CollisionShape2D.disabled = false

func turn_light_off():
	var rgb_prev = $Sprite.modulate
	$Sprite.modulate = Color(rgb_prev.r, GREEN_LIGHT_OFF, rgb_prev.b)
	
func turn_light_on():
	var rgb_prev = $Sprite.modulate
	$Sprite.modulate = Color(rgb_prev.r, GREEN_LIGHT_ON, rgb_prev.b)

