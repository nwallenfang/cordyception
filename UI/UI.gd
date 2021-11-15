extends CanvasLayer
class_name UI

var show_health := false setget set_show_health
var show_shoot := false setget set_show_shoot
var show_dash := false setget set_show_dash

func _ready() -> void:
	# everything starts transparent (only with modulate)
	$HealthUI.modulate = Color.transparent
	$ProjectileCooldownUI.modulate = Color.transparent
	$DashCooldownUI.modulate = Color.transparent
	$HealthUI.visible = true
	$ProjectileCooldownUI.visible = true
	$DashCooldownUI.visible = true

func set_show_health(show: bool) -> void:
	if show_health != show:
		show_health = show
		$Tween.interpolate_property($HealthUI, "modulate", Color.transparent if show else Color.white, Color.white if show else Color.transparent, 1)
		$Tween.start()

func set_show_shoot(show: bool) -> void:
	if show_shoot != show:
		show_shoot = show
		$Tween.interpolate_property($ProjectileCooldownUI, "modulate", Color.transparent if show else Color.white, Color.white if show else Color.transparent, 1)
		$Tween.start()

func set_show_dash(show: bool) -> void:
	if show_dash != show:
		show_dash = show
		$Tween.interpolate_property($DashCooldownUI, "modulate", Color.transparent if show else Color.white, Color.white if show else Color.transparent, 1)
		$Tween.start()

func cooldown_not_ready_visual():
	# TODO reference argument, which skill cooldown is not ready
	pass

func set_hearts(value):
	$HealthUI.set_hearts(value)
	

