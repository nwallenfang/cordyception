extends TextureProgress


export var MAX_HEALTH: int = 100


onready var health := MAX_HEALTH setget set_health


func set_health(new_health) -> void:
	# health bar shouldn't be responsible for such logic checks but just to make
	# sure..
	new_health = min(new_health, MAX_HEALTH)
	$Tween.interpolate_property(self, 'value', self.value, new_health, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)

func _ready() -> void:
	pass
