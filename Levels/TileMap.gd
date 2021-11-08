tool
extends TileMap

func _ready() -> void:
	fix_invalid_tiles()
	update_dirty_quadrants()
	update_bitmask_region()
