tool
extends TileMap

export var do_nothing := true

func _ready() -> void:
	if !do_nothing:
		fix_invalid_tiles()
		update_dirty_quadrants()
		update_bitmask_region()
