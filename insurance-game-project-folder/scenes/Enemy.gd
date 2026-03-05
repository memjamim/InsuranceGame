extends Control
class_name Enemy

signal died(enemy: Enemy)

@export var data: EnemyData
var hp: int

@onready var icon: TextureRect = $VBoxContainer/Icon
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var hp_bar: ProgressBar = $VBoxContainer/HPBar

func _ready():
	if data == null:
		data = EnemyData.new()
	hp = data.max_hp
	_refresh_ui()

func choose_move() -> int:
	var total = data.weight_attack + data.weight_block + data.weight_dodge
	var r = randi_range(1, max(1, total))
	if r <= data.weight_attack:
		return CombatResolver.Move.ATTACK
	r -= data.weight_attack
	if r <= data.weight_block:
		return CombatResolver.Move.BLOCK
	return CombatResolver.Move.DODGE

func take_damage(amount: int):
	hp = max(0, hp - amount)
	_refresh_ui()
	if hp <= 0:
		died.emit(self)
		queue_free()

func _refresh_ui():
	name_label.text = "%s" % data.enemy_name
	hp_bar.max_value = data.max_hp
	hp_bar.value = hp
	if data.sprite_texture != null:
		icon.texture = data.sprite_texture
