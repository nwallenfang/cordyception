extends TextureProgress


export var MAX_HEALTH: int = 200 setget set_max


onready var health := MAX_HEALTH setget set_health

var faded_out =  Color("00ffffff")
var faded_in = Color("ffffffff")
func _ready() -> void:
	pass

func set_max(new_max) -> void:
	MAX_HEALTH = new_max
	max_value = new_max
	set_health(new_max)

func set_health(new_health) -> void:
	# health bar shouldn't be responsible for such logic checks but just to make
	# sure..
#	print("new: ", new_health)
	new_health = min(new_health, MAX_HEALTH)
	
	health = new_health
	self.value = health
	
#	print(self.value, " / ", self.max_value)
	

	
	
