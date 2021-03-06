tool
extends StaticBody2D

enum ShroomColor {
	GREEN, BROWN, BLUE, VIOLET
}

const GREEN_SPRITE := preload("res://World/Shrooms/Pilz_01_Green.png")
const BROWN_SPRITE := preload("res://World/Shrooms/Pilz_01_Brown.png")
const BLUE_SPRITE := preload("res://World/Shrooms/Pilz_01_Blue.png")
const VIOLET_SPRITE := preload("res://World/Shrooms/Pilz_01_Violet.png")

onready var sprite = $Sprite
export(ShroomColor) var color : int setget set_color

func _ready() -> void:
	set_color(color)

func set_color(new_color) -> void:
	color = new_color
	if sprite != null:
		match color:
			ShroomColor.GREEN:
				sprite.texture = GREEN_SPRITE
			ShroomColor.BROWN:
				sprite.texture = BROWN_SPRITE
			ShroomColor.BLUE:
				sprite.texture = BLUE_SPRITE
			ShroomColor.VIOLET:
				sprite.texture = VIOLET_SPRITE
