extends Control

export var hearts = 4 setget set_hearts
export var max_hearts = 4 setget set_max_hearts

const SPACE = 22
const SINGLE_HEART = preload("res://UI/SingleHeartUI.tscn")

var heart_list : Array = []

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	for i in range(hearts):
		heart_list[i].alive = true
	for i in range(hearts, max_hearts):
		heart_list[i].alive = false
	
func set_max_hearts(value):
	max_hearts = max(value, 1)
	for heart in heart_list:
		heart.queue_free()
	heart_list.clear()
	for i in range(max_hearts):
		var heart = SINGLE_HEART.instance()
		heart.position.x = i * SPACE
		heart.position.y = 0
		add_child(heart)
		heart_list.append(heart)
	set_hearts(hearts)

func _ready() -> void:
	self.max_hearts = GameStatus.PLAYER_MAX_HEALTH
	self.hearts = GameStatus.CURRENT_HEALTH

func play_hearts_animation():
	for heart in heart_list:
		heart.animate()
