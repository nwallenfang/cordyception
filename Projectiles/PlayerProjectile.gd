extends Projectile

export var GREEN_LIGHT_ON := 1.8
export var GREEN_LIGHT_OFF := 1.1


func turn_light_off():
	var rgb_prev = $Sprite.modulate
	$Sprite.modulate = Color(rgb_prev.r, GREEN_LIGHT_OFF, rgb_prev.b)
	
func turn_light_on():
	var rgb_prev = $Sprite.modulate
	$Sprite.modulate = Color(rgb_prev.r, GREEN_LIGHT_ON, rgb_prev.b)

