extends Sprite2D
class_name Citro2DSprite


@export var enabled_by_default: bool = true
@export var group: String = "Game"
@export_enum("Top Screen", "Bottom Screen") var screen: int = 0
@export var sheet_variable: String = "spriteSheet0"
@export var sheet_sprite_num: int = 0
@export var configs: Array[CitroSpriteConfig]


func _enter_tree():
	add_to_group("CitroSprite")
