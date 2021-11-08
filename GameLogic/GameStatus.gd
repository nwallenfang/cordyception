extends Node

export var ENEMY_BEHAVIOR := true

export var PLAYER_MAX_HEALTH := 4
export var PLAYER_DASH_SPEED := 650.0
export var PLAYER_PROJECTILE_DAMAGE := 4
export var PLAYER_PROJECTILE_KNOCKBACK := 450.0
export var PLAYER_CLOSECOMBAT_DAMAGE := 2
export var PLAYER_CLOSECOMBAT_KNOCKBACK := 250.0
export var PLAYER_POISON_DAMAGE := 1

var CURRENT_HEALTH := PLAYER_MAX_HEALTH setget set_health

var CURRENT_YSORT: YSort
var CURRENT_UI: UI
var CURRENT_PLAYER: Player


func set_health(new_health:int):
	CURRENT_HEALTH = new_health
	CURRENT_UI.get_node("HealthUI").set_hearts(new_health)
	
