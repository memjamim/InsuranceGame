extends Resource
class_name EnemyData

@export var enemy_name: String = "Disease"
@export var max_hp: int = 12
@export var power: int = 5
@export var defense: int = 1
@export var sprite_texture: Texture2D

@export_range(0, 100) var weight_attack: int = 50
@export_range(0, 100) var weight_block: int = 25
@export_range(0, 100) var weight_dodge: int = 25
