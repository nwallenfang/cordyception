extends TextureProgress


export var MAX_HEALTH: int = 200 setget set_max


onready var health := MAX_HEALTH setget set_health

func set_max(new_max) -> void:
	MAX_HEALTH = new_max
	max_value = new_max
	set_health(new_max)

func set_health(new_health) -> void:
	# health bar shouldn't be responsible for such logic checks but just to make
	# sure..
	new_health = min(new_health, MAX_HEALTH)
	health = new_health
	self.value = health
#	$Tween.interpolate_property(self, 'value', self.value, new_health, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)

func _ready() -> void:
	pass
