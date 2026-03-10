extends Control
class_name Enemy

signal died(enemy: Enemy)
signal selected(enemy: Enemy)
@export var data: EnemyData
var hp: int
var is_selected: bool = false
@export var base_name: String = "Disease"
@export_range(0, 100) var weight_wait: int = 25
@onready var icon: TextureRect = $VBoxContainer/Icon
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var hp_bar: ProgressBar = $VBoxContainer/HPBar
@onready var selection_frame: Control = $SelectionFrame
@onready var vbox: Control = $VBoxContainer

func _ready():
	if data == null:
		data = EnemyData.new()
	hp = data.max_hp

	mouse_filter = Control.MOUSE_FILTER_STOP

	if vbox != null:
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if icon != null:
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if name_label != null:
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if hp_bar != null:
		hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if selection_frame != null:
		selection_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_refresh_ui()

func choose_move() -> int:
	var total: int = data.weight_attack + data.weight_block + data.weight_dodge + data.weight_wait
	var r: int = randi_range(1, max(1, total))

	if r <= data.weight_attack:
		return CombatResolver.Move.ATTACK
	r -= data.weight_attack

	if r <= data.weight_block:
		return CombatResolver.Move.BLOCK
	r -= data.weight_block

	if r <= data.weight_dodge:
		return CombatResolver.Move.DODGE

	return CombatResolver.Move.NONE

func take_damage(amount: int):
	hp = max(0, hp - amount)
	_refresh_ui()
	if hp <= 0:
		died.emit(self)
		queue_free()

func set_selected(v: bool):
	is_selected = v
	if selection_frame != null:
		selection_frame.visible = v

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected.emit(self)
			accept_event()

func _refresh_ui():
	name_label.text = "%s" % data.enemy_name
	hp_bar.max_value = data.max_hp
	hp_bar.value = hp
	if data.sprite_texture != null:
		icon.texture = data.sprite_texture

	if selection_frame != null:
		selection_frame.visible = is_selected
