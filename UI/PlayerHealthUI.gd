# courtesy of HeartBeast <3 https://www.youtube.com/user/uheartbeast 
extends Control



var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts


func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if $HeartUIFull != null:
		$HeartUIFull.rect_size.x = hearts * 15
	
func set_max_hearts(value):
	max_hearts = max(value, 1)
	if $HeartUIEmpty != null:
		$HeartUIEmpty.rect_size.x = max_hearts * 15

func _ready() -> void:
	self.max_hearts = GameStatus.PLAYER_MAX_HEALTH
	self.hearts = GameStatus.CURRENT_HEALTH
	#PlayerStats.connect("health_changed", self, "set_hearts")
	#PlayerStats.connect("max_health_changed", self, "set_max_hearts")
